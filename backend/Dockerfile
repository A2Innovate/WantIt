FROM denoland/deno:2.3.1

WORKDIR /app

COPY . .

RUN deno task install

EXPOSE 8000

CMD ["task", "start"]