# WantIt Backend

## Setup

First, install the dependencies:

```
deno task install
```

Then, copy the `.env.sample` file to `.env` and fill in the environment
variables.

```
cp .env.sample .env
```

Then you can push the schema to the database (After most features are working,
there will be migrations instead):

```
deno task db:push
```

## Development

Start the development server:

```
deno task dev
```

Format the code:

```
deno fmt
```

Lint the code:

```
deno lint
```

## Production

Start the production server:

```
deno task start
```
