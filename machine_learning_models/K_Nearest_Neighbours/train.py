import numpy as np
from sklearn import datasets
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from K_Nearest_Neighbours import KNN

cmap = ListedColormap(['#FF0000', '#00FF00', '#0000FF'])

iris = datasets.load_iris()
X, y = iris.data, iris.target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.5, random_state=1)

plt.figure()
plt.scatter(X[:, 2], X[:, 3], c=y, cmap=cmap, edgecolors='k', s=20)
plt.show()

classifier = KNN(k=5)
classifier.fit(X_train, y_train)
predictions = classifier.predict(X_test)

print('We have the following predictions: ', predictions)


accuracy = np.sum(predictions == y_test)/len(y_test)

print('And the accuracy is: ', accuracy)
