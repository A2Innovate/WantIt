FROM denoland/deno:2.3.5

WORKDIR /app

COPY . .

RUN deno install

EXPOSE 8000

CMD ["task", "start"]