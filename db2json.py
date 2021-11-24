#!/usr/bin/env python3

import pandas as pd
import sqlite3

conn = sqlite3.connect("data/data.db")

df_story = pd.read_sql_query("Select * from Story", conn)
df_type = pd.read_sql_query("Select * from Type", conn)
df_url = pd.read_sql_query("Select * from Url", conn)
df_comment = pd.read_sql_query("Select * from Comment", conn)

df = df_story.join(df_type, on="story_type")
df = df.merge(df_url, left_on="story_id", right_on="url_story", how="left")
print(df.shape)
print(df_story.shape)
print(df.isnull().sum())
