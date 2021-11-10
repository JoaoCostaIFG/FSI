#!/bin/python
import json
from numpy import NaN
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import create_engine
import sys
import numpy as np
import datetime

# Some base vars
out_folder = "docs/plots/"
show = True
if (len(sys.argv) > 1):
    show = True if sys.argv[1] == "true" else False
    if (len(sys.argv) > 2):
        out_folder = sys.argv[2]
color = "orange"
plt.rcParams['font.size'] = 16
plt.rcParams['figure.autolayout'] = True



# Load Database
engine = create_engine("sqlite:///data.db", echo=False)
stories_df = pd.read_sql_query(
    '''SELECT * FROM Story JOIN Type ON(story_type = type_id)''', con=engine)

comments_df = pd.read_sql_query(
    '''SELECT * FROM Comment''', con=engine)

url_df = pd.read_sql_query(
    '''SELECT * FROM Url''', con=engine)

# Convert Unix timestamp to date
stories_df["story_time"] = pd.to_datetime(stories_df['story_time'], unit='s')


def plot_heatmap_score(df):
    median_score = df.groupby([df['story_time'].dt.hour, df['story_time'].dt.weekday])[
        'story_score'].mean().rename_axis(['hour', 'day']).reset_index()
    print(median_score)
    median_score = median_score.pivot(
        index='hour', columns='day', values='story_score')
    sns.heatmap(median_score, annot=True, fmt="g", cmap='viridis',
                xticklabels=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])

    if (show):
        plt.show()
    else:
        plt.savefig('books_read.png')
plot_heatmap_score(stories_df)


# Numero de posts/score por mes ou hora ou dia
def posts_per_time(df):
    plt.rcParams['font.size'] = 12
    months = {i: datetime.date(2000, i, 1).strftime('%b')
              for i in range(1, 13)}
    days = {i-3: datetime.date(2000, 1, i).strftime('%A')
            for i in range(3, 10)}

    plt.subplot(2, 2, 1)
    month_plot = df.groupby(df['story_time'].dt.month).size().rename(
        months).plot(kind="bar", rot=0, xlabel="Months", ylabel="Number of Stories", color=color)

    plt.subplot(2, 2, 2)
    days_plot = df.groupby(df['story_time'].dt.weekday).size().rename(
        days).plot(kind="bar", rot=0, xlabel="Days", ylabel="Number of Stories", color=color)

    plt.subplot(2, 1, 2)
    hour_plot = df.groupby(df['story_time'].dt.hour).size().plot(
        kind="bar", rot=0, xlabel="Hour", ylabel="Number of Stories", color=color)

    if (show):
        plt.show()
    else:
        plt.savefig('books_read.png')
posts_per_time(stories_df)

# + bar plot com tipo de posts


def posts_per_type(df):
    bars = df['type_name'].value_counts().plot.bar(
        rot=0, color=color, xlabel="Type", ylabel="Number of Stories")
    for p in bars.patches:
        bars.annotate(str(p.get_height()), (p.get_x() + 0.50 *
                      p.get_width(), p.get_y() + p.get_height() + 300.5), va="center", ha="center")

    if (show):
        plt.show()
    else:
        plt.savefig('books_read.png')


posts_per_type(stories_df)

# + Numero de descendentes por posts


def descendants_per_type(df):  # TODO maybe pass groupby by arg
    df.columns = df.columns.str.replace('type_name', 'Type')
    df.columns = df.columns.str.replace(
        'story_descendants', 'Number of Comments')
    sns.violinplot(data=df, x="Type", y="Number of Comments")

    if (show):
        plt.show()
    else:
        plt.savefig('books_read.png')


descendants_per_type(stories_df)


# + Numero de descendentes por score

def score_per_descendants(df):  # TODO maybe pass groupby by arg
    # Done with bar plot
    # desc_min, desc_max = df['story_descendants'].min(
    # ), df['story_descendants'].max()
    # steps = 100
    # bins = [i for i in range(desc_min, desc_max + 1,
                             # (desc_max - desc_min) // steps)]
    # df = df.groupby(pd.cut(df['story_descendants'], bins=bins))[
        # 'story_score'].median()
    # df.plot.bar()

    # Done with line plot
    plot = df.groupby(df['story_descendants'])[
                      'story_score'].median().plot(color=color)
    plot.set_xlabel("Number of Descendants")
    plot.set_ylabel("Score")

    if (show):
        plt.show()
    else:
        plt.savefig('books_read.png')


score_per_descendants(stories_df)
# + Estimativa de numero total de comments
# Stories têm numero total de comments dela
# Calcular percentagem de comments que pertencem ao primeiro comment

def comment_percentage(story_df, comment_df):
    # print(comment_df)
    def get_percentage(tup):
        comment = comment_df[comment_df["comment_parent"] == tup['story_id']]

        if (len(comment) > 0):
            comment_descendants = comment.iloc[0]['comment_descendants']
            story_descendants = tup['story_descendants']
            return comment_descendants / story_descendants
        else:
            return 0
    story_df['top_comment_perc'] = story_df.apply(get_percentage, axis=1)
    print(story_df['top_comment_perc'].median())
comment_percentage(stories_df, comments_df)


# + dominios mais postados
def more_domains(url_df, story_df):
    # From https://stackoverflow.com/questions/44021846/extract-domain-name-from-url-in-python
    def domain_name(url):
        return url.split("www.")[-1].split("//")[-1].split(".")[0]

    # Clean URL
    url_df['url_url'] = url_df['url_url'].apply(domain_name)
    df = pd.merge(url_df, story_df, left_on='url_story',
                  right_on="story_id", how="inner")

    p = df.groupby(df['url_url']).count()['url_id'].sort_values(
        ascending=False).head(20).plot.bar(color=color)
    p.x_label = "Domain"
    p.y_label = "Number of Posts with that URL"

    if (show):
        plt.show()
    else:
        plt.savefig('books_read.png')
    # print(url_df['url_url'])
more_domains(url_df, stories_df)
