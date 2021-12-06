#!/usr/bin/env python3

import pandas as pd
import sqlite3

conn = sqlite3.connect("data/data.db")

df_story = pd.read_sql_query("Select * from Story", conn)
df_type = pd.read_sql_query("Select * from Type", conn)
df_url = pd.read_sql_query("Select * from Url", conn)

df = df_story.join(df_type, on="story_type")
df = df.merge(df_url, left_on="story_id", right_on="url_story", how="left")
df["story_time"] = pd.to_datetime(df["story_time"], unit="s")
df["story_time"] = df["story_time"].dt.strftime("%Y-%m-%dT%H:%M:%S")
df.drop(["story_type", "type_id", "url_id", "url_story"], axis=1, inplace=True)
df.rename(
    columns={
        "story_by": "story_author",
        "type_name": "story_type",
        "url_url": "url",
    }
)


def filter_comments(id):
    df_slice = df_comment[df_comment["comment_parent"] == id].copy()
    df_slice.drop(["comment_parent"], axis=1, inplace=True)
    df_slice["comment_time"] = pd.to_datetime(df_slice["comment_time"], unit="s")
    df_slice["comment_time"] = df_slice["comment_time"].dt.strftime("%Y-%m-%dT%H:%M:%S")
    df_slice.rename(
        columns={
            "comment_by": "comment_author",
        }
    )
    return df_slice


df_comment = pd.read_sql_query("Select * from Comment", conn)
df["comments"] = df["story_id"].map(filter_comments)

df.to_json("hackersearch.json", orient="records")
