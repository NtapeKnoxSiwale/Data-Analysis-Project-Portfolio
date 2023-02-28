import numpy as np
from collections import Counter


def euclidean_distance(x_1, x_2):
    distance = np.sqrt(np.sum((x_1 - x_2)**2))
    return distance


class KNN:
    def __init__(self, k=3):
        self.k = k

    def fit(self, X, y):
        self.X_train = X
        self.y_train = y

    # predict function to calculate the distance
    def predict(self, X):
        predictions = [self._predict(x) for x in X]
        return predictions

    # helper function
    def _predict(self, x):

        # compute the dsitances
        distances = [euclidean_distance(x, x_train)
                     for x_train in self.X_train]

        # getting the closest k
        k_indices = np.argsort(distances)[:self.k]
        k_nearest_labels = [self.y_train[i] for i in k_indices]

        # determine the lable with the majority vote
        most_common = Counter(k_nearest_labels).most_common()
        return most_common[0][0]
