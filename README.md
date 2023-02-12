# Differentially Private TEE - Frontend

Simple web app that uploads a file containing a numeric dataset and sends it to a TCP server running under an enclave. The application is using the [elm platform](https://elm-lang.org/).

## Requirements

- [elm](https://elm-lang.org/) language installed

## How to run the app

```bash
git clone https://github.com/jbgriesner/dptee-frontend.git
cd dptee-frontend
elm make src/HomePage.elm --output elm.js
elm reactor
```

Then select `index.html`.
