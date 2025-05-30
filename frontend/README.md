# WantIt Frontend

## Setup

Make sure to install dependencies:

```bash
pnpm install
```

Then, copy the `.env.sample` file to `.env` and fill in the environment
variables.

```
cp .env.sample .env
```

## Development

Start the development server on `http://localhost:3000`:

```bash
pnpm run dev
```

Format the code:

```bash
pnpm run format
```

Lint (with auto fix) the code:

```bash
pnpm run lint:fix
```

## Production

Build the application for production:

```bash
pnpm run build
```

Locally preview production build:

```bash
pnpm run preview
```
