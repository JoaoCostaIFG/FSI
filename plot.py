#!/bin/python
import json
from numpy import NaN
import pandas as pd
import matplotlib.pyplot as plt

# Load File
f = open('stories.json',)
data = json.load(f)
df = pd.DataFrame.from_dict(data, orient='columns')

# Set NaN to dead=false
df["dead"].fillna(False, inplace=True)

# Convert Unix timestamp to date
df["time"] = pd.to_datetime(df['time'], unit='s')


def groupby_month(df):
    return df.groupby(df['time'].dt.month)


def groupby_year(df):
    return df.groupby(df['time'].dt.year)


def groupby_trimester(df):
    return df.groupby(pd.Grouper(key='time', freq='3M'))


def groupby_author(df):
    return df.groupby(df['by'])


def plot_top_count(df, N=50):
    top50 = df['id'].count().sort_values(ascending=False).head(N)
    top50.plot(kind="bar")
    plt.show()


def plot_top_posts_by_comment(df, N=50):
    df['kids'] = df['kids'].apply(len)
    top50 = df.sort_values(['kids'], ascending=False).head(N)
    print(top50.head())
    top50.plot(kind="bar", x="id", y="kids")
    plt.show()


def plot_top_posts_by_score(df, N=50):
    top50 = df.sort_values(['score'], ascending=False).head(N)
    top50.plot(kind="bar", x="id", y="score")
    plt.show()


def plot_count(df):
    df['id'].count().plot(kind="line")
    plt.show()


def plot_score(df):
    df['score'].mean().plot(kind="bar")
    plt.show()


def plot_dead(df):
    df.groupby("dead").size().plot(kind="bar")
    plt.show()


# plot_dead(df)
# groupby_trimester(df)['id'].count().plot(kind="line")
# plot_count(groupby_trimester(df))
# plot_top_count(groupby_author(df))
plot_top_posts_by_score(df)
# plot_top_posts_by_comment(df)
