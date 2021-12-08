#!/bin/python

import sys
import json


def ap(docs, n=10):
    """Average Precision"""
    precision_values = [
        len([
            doc
            for doc in docs[:idx]
            if doc["relevant"] == "true"
        ]) / idx
        for idx in range(1, n + 1)
    ]
    return sum(precision_values) / len(precision_values)


def p10(docs, n=10):
    """Precision at N"""
    return len([doc for doc in docs[:n] if doc['relevant'] == "true"]) / n


def rec(docs, n=10):
    """Recall"""
    len_relevant = getNoRelevants(docs)
    return len([
        doc for doc in docs[:n]
        if doc['relevant'] == "true"
    ]) / len_relevant


def f1(docs, n=10):
    """F1 Score"""
    precision = p10(docs, n)
    recall = rec(docs, n)
    return 2 * (precision * recall) / (precision + recall)


def getNoRelevants(docs):
    return sum([doc["relevant"] == "true" for doc in docs])


def gen_precisions(docs, n=10):
    return [getNoRelevants(docs[:idx]) / idx
            for idx, _ in enumerate(docs[:n], start=1)]


def gen_recalls(docs, n=10):
    len_relevant = getNoRelevants(docs)
    return [
        len([
            doc for doc in docs[:idx]
            if doc['relevant'] == "true"
        ]) / len_relevant
        for idx, _ in enumerate(docs[:n], start=1)
    ]


def plot_recall_precision(recall_values, precision_values):
    import matplotlib.pyplot as plt
    from sklearn.metrics import PrecisionRecallDisplay
    import numpy as np

    print(recall_values, precision_values)

    # Let's scatterplot all recall-precision values
    # And lineplot using sklearn the curve with intermediate steps
    precision_recall_match = [
        (i, recall_values[i], precision_values[i]) for i in range(len(recall_values))]

    set_recalls = set(recall_values)
    # Extend recall_values to include traditional steps for a better curve(0.1, 0.2 ...)
    recall_values.extend([step for step in np.arange(
        0.1, 1.1, 0.1) if step not in recall_values])
    recall_values = sorted(set(recall_values))

    recall_precision_dict = {v[1]: v[2] for v in precision_recall_match}
    # Extend matching dict to include these new intermediate steps
    for idx, step in enumerate(recall_values):
        if step not in set_recalls:  # If we don't have info on this step
            if recall_values[idx-1] in recall_precision_dict and idx != 0:
                recall_precision_dict[step] = recall_precision_dict[recall_values[idx-1]]
            else:
                recall_precision_dict[step] = recall_precision_dict[recall_values[idx+1]]

    # Get recalls for scatterplot
    recalls = [precision_recall_match[i][1]
               for i in range(len(precision_recall_match))]
    precisions = [precision_recall_match[i][2]
                  for i in range(len(precision_recall_match))]
    a = plt.figure()
    axes = a.add_axes([0.1, 0.1, 0.8, 0.8])

    # Use dict with extended values to draw line
    disp = PrecisionRecallDisplay(
        precisions, recalls)
    disp.plot(ax=axes)
    axes.set_ylim([0, 1])
    plt.scatter(recalls, precisions)
    plt.savefig("precision_recall")
    plt.show()

# Calculate all metrics and export results as LaTeX table
# df = pd.DataFrame([['Metric', 'Value']] +
# [
# [evaluation_metrics[m], calculate_metric(m, results, relevant)]
# for m in evaluation_metrics
# ]
# )


if len(sys.argv) != 2:
    print("Usage: ./evaluate.py qrel.json")
    exit(-1)

f = open(sys.argv[1])
data = json.load(f)

print("Average Precision: {:.2%}".format(ap(data["docs"])))
print("P@10: {:.2%}".format(p10(data["docs"])))
print("Recall: {:.2%}".format(rec(data["docs"])))
print("F1: {:.2%}".format(f1(data["docs"])))

plot_recall_precision(gen_recalls(data["docs"]), gen_precisions(data["docs"]))
