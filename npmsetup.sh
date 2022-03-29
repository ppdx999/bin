#!/bin/sh

cat << EOF >> package.json
{
  "name": "",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "jest",
    "start": "webpack serve",
    "watch": "webpack --watch",
    "build": "webpack --mode production"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF
npm i -D @babel/core
npm i -D @babel/preset-env
npm i -D @babel/preset-typescript
npm i -D @types/jest
npm i -D babel-loader
npm i -D html-webpack-plugin
npm i -D jest
npm i -D ts-loader
npm i -D typescript
npm i -D webpack
npm i -D webpack-cli webpack-dev-server

cat <<EOF >> webpack.config.js
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
  mode: "development",
  entry: "./src/index.ts",
  output: {
    path: path.resolve(__dirname, "dist/"),
  },
  module: {
    rules: [
      {
        test: /\.(ts|tsx)$/,
        use: ["ts-loader"],
        exclude: /node_modules/,
      },
      {
        test: /\.(js|jsx)$/,
        use: ["babel-loader"],
      },
    ],
  },
  resolve: {
    extensions: [".ts", ".js", ".tsx", ".jsx", ".json"],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/index.html",
    }),
  ],
  devServer: {
    static: {
      directory: path.join(__dirname, "dist"),
    },
  },
};
EOF

 cat << EOF >> tsconfig.json
 {
   "compilerOptions": {
     "target": "es5",
     "module": "commonjs",
     "outDir": "dist",
     "strict": true,
     "moduleResolution": "node",
     "allowSyntheticDefaultImports": true,
     "esModuleInterop": true,
     "skipLibCheck": true,
     "forceConsistentCasingInFileNames": true,
     "jsx": "react"
   },
   "include": ["src"]
 }
EOF

mkdir src
cat << EOF >> src/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title></title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF
