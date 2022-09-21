# Can't Stop - Game Analysis

This repository is designed to explore the mathematical underpinnings of
the Can't Stop dice game.

Briefly, each player rolls 4 dice, and then groups them into 2 pairs.  The
point values of each pair can be used to advance your marker in one of 11
tracks (for point values 2 through 12).

This repo seeks to answer:

- What is the probability of rolling each point value on each roll (e.g.
  what is the change of rolling a "7" pair in a roll of 4 dice).
- What is the probability of "crapping out" depending on which (3) point values
  the users is working on in the current turn.

## Installation

The primary file here is a [Jupyter Notebook](./index.ipynb) - which you can just
visit here if you want to view it statically.

If you want to run the Python code in the notebook, follow these steps.

*I'll assume you have Python3 installed on your system already.*

```
$ python -m venv .env        # Create a local Virtual Environment
$ source .env/bin/activate   # Activate it

# Confirm python 3 and pip are both coming from the environment:

$ which python && python --version
$ which pip

$ pip install -r requirements.txt

# Confirm Jupyter notebook installed

$ which jupyter && jupyter --version

# Run the notebook opening a browser window:

$ jupyter notebook index.ipynb
```

As an alternative to running the Notebook in a browser, you can open it in
VS-Code.  Install all the same code above, but then open VS-Code in this
folder and open index.ipynb.  In the upper right, select ".env" as your
Python environment.

VS-Code will launch the kernel for you.

