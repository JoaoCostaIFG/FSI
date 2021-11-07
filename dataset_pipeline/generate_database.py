#!/usr/bin/env python3
#
#
#

import pandas as pd
from pandas.core.frame import DataFrame
import numpy as np
from html import unescape
from sqlalchemy import create_engine

# IMPORT DATA #
df_stories = DataFrame(pd.read_json("stories.json"))
df_comments = DataFrame(pd.read_json("comments.json"))
df_urls = DataFrame(pd.read_json("html_content.json"))

# DEAL WITH STORIES #
# we can drop the stories' kids collumn as it doesn't contain useful information
# for us (it is redundant with the parent attribute of the comments' data)
df_stories.drop(["kids"], axis=1, inplace=True)

# we have many null urls and text
#  print(df_stories.isnull().sum())
# fill them with empty string
df_stories.fillna("", inplace=True)

# (re-)classify story types:
# LaunchHN, AskHN, ShowHN, SelfPost, Normal
# the type is all the same => we can drop it
#  print(df_stories.groupby("type").size())
df_stories.drop(["type"], axis=1, inplace=True)

story_type_conds = [
    (
        (df_stories["title"].str.startswith("Launch HN:", 0))
        | (df_stories["title"].str.startswith("Launch YC", 0))
    ),
    (df_stories["title"].str.startswith("Show HN:", 0)),
    ((df_stories["title"].str.startswith("Ask HN:", 0))
     | (df_stories["url"] == "")),
    (df_stories["url"] != ""),
]
story_types = ["LanchHN", "ShowHN", "AskHN", "Normal"]
df_stories["type"] = np.select(story_type_conds, story_types)

# let's unescape the html entities contained in the textual data
df_stories["title"] = df_stories["title"].map(unescape)
df_stories["text"] = df_stories["text"].map(unescape)

# DEAL WITH COMMENTS #
# we have many null 'kids' attribute
#  print(df_comments.isnull().sum())
# we can fill them with an empty array (we're not using fillna() because it doesn't accept lists)
df_comments["kids"] = df_comments["kids"].apply(
    lambda d: d if isinstance(d, list) else []
)

# the type is all the same => we can drop it
#  print(df_comments.groupby("type").size())
df_comments.drop(["type"], axis=1, inplace=True)

# we can compress the kids column into a descendants column
df_comments["descendants"] = df_comments["kids"].map(len)
df_comments.drop(["kids"], axis=1, inplace=True)

# let's unescape the html entities contained in the textual data
df_comments["text"] = df_comments["text"].map(unescape)

# DEAL WITH URL CONTENT #
# move the urls to the url content dataframe
df_urls = df_urls.join(df_stories[["id", "url"]].set_index("id"), on="id")

# USE SQL #
# create sql connection
engine = create_engine("sqlite:///data.db", echo=False)
engine.execute("PRAGMA foreign_keys = ON")

# Type
engine.execute("DROP TABLE IF EXISTS Type")
engine.execute(
    "CREATE TABLE Type (\
        type_id INTEGER PRIMARY KEY ASC,\
        type_name TEXT)"
)
engine.execute(
    "INSERT INTO Type(type_id, type_name)\
        VALUES(0, ?), (1, ?), (2, ?), (3, ?)",
    *story_types
)

# Story
engine.execute("DROP TABLE IF EXISTS Story")
engine.execute(
    "CREATE TABLE Story (\
        story_id INTEGER PRIMARY KEY,\
        story_by TEXT NOT NULL,\
        story_descendants INTEGER NOT NULL DEFAULT 0,\
        story_score INTEGER NOT NULL DEFAULT 1,\
        story_time INTEGER NOT NULL,\
        story_title TEXT NOT NULL,\
        story_text TEXT,\
        story_type INTEGER NOT NULL,\
        FOREIGN KEY(story_type) REFERENCES Type)"
)
with engine.begin() as conn:
    for _, story in df_stories.iterrows():
        conn.execute(
            "INSERT INTO Story\
                VALUES(?, ?, ?, ?, ?, ?, ?, ?)",
            story["id"],
            story["by"],
            story["descendants"],
            story["score"],
            story["time"],
            story["title"],
            story["text"],
            story_types.index(story["type"]),
        )

# Comment
engine.execute("DROP TABLE IF EXISTS Comment")
engine.execute(
    "CREATE TABLE Comment (\
        comment_id INTEGER PRIMARY KEY,\
        comment_by TEXT NOT NULL,\
        comment_descendants INTEGER NOT NULL DEFAULT 0,\
        comment_time INTEGER NOT NULL,\
        comment_text TEXT,\
        comment_parent INTEGER NOT NULL,\
        FOREIGN KEY(comment_parent) REFERENCES Story)"
)
with engine.begin() as conn:
    for _, comment in df_comments.iterrows():
        conn.execute(
            "INSERT INTO Comment\
                VALUES(?, ?, ?, ?, ?, ?)",
            comment["id"],
            comment["by"],
            comment["descendants"],
            comment["time"],
            comment["text"],
            comment["parent"],
        )

# URL content
engine.execute("DROP TABLE IF EXISTS Url")
engine.execute(
    "CREATE TABLE Url (\
        url_id INTEGER PRIMARY KEY,\
        url_url TEXT NOT NULL,\
        url_text TEXT NOT NULL,\
        url_story INTEGER NOT NULL,\
        FOREIGN KEY(url_story) REFERENCES Story)"
)
with engine.begin() as conn:
    for _, url in df_urls.iterrows():
        conn.execute(
            "INSERT INTO Url(url_url, url_text, url_story)\
                VALUES(?, ?, ?)",
            url["url"],
            url["html_content"],
            url["id"],
        )

# Remove posts that can't be worked with
engine.execute(
    "DELETE FROM Story\
        WHERE story_id IN\
        (SELECT story_id\
        FROM Url LEFT JOIN Story ON (url_story = story_id)\
        WHERE url_text = '' and story_text = '')"
)
