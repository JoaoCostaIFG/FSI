#!/usr/bin/env python3
#
#
#

import pandas as pd
from pandas.core.frame import DataFrame
import numpy as np
from html import unescape

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
# AskHN, ShowHN, SelfPost, Normal
# the type is all the same => we can drop it
#  print(df_stories.groupby("type").size())
df_stories.drop(["type"], axis=1, inplace=True)

story_type_conds = [
    (df_stories["title"].str.startswith("Ask HN:", 0)),
    (df_stories["title"].str.startswith("Show HN:", 0)),
    (df_stories["url"] == ""),
    (df_stories["url"] != ""),
]
story_types = ["AskHN", "ShowHN", "SelfPost", "Normal"]
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
