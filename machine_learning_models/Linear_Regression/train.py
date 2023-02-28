import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import datasets
import matplotlib.pyplot as plt
from Linear_Regression import LinearRegression

X, y = datasets.make_regression(
    n_samples=100, n_features=1, noise=20, random_state=1)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=1234)

fig = plt.figure(figsize=(8, 6))
plt.scatter(X[:, 0], y, color="b", marker="o", s=35)
plt.show()

model = LinearRegression(learning_rate=0.01)
model.fit(X_train, y_train)
predictions = model.predict(X_test)


def MSE(y_test, predictions):
    return np.mean((y_test - predictions)**2)


mse = MSE(y_test, predictions)
print(mse)

y_prediction_line = model.predict(X)
cmap = plt.get_cmap("viridis")
fig = plt.figure(figsize=(8, 6))
m_1 = plt.scatter(X_train, y_train, color=cmap(0.9), s=15)
m_1 = plt.scatter(X_test, y_test, color=cmap(0.5), s=15)
plt.plot(X, y_prediction_line, color='black', linewidth=2)
plt.show()
