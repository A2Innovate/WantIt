import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  host: Deno.env.get("SMTP_HOST"),
  port: Number(Deno.env.get("SMTP_PORT")),
  secure: Deno.env.get("SMTP_SECURE") === "true",
  auth: {
    user: Deno.env.get("SMTP_USER"),
    pass: Deno.env.get("SMTP_PASSWORD"),
  },
});

export async function sendMail(
  { to, subject, text }: { to: string; subject: string; text: string },
) {
  await transporter.sendMail({
    from: Deno.env.get("SMTP_FROM"),
    to,
    subject,
    text,
  });
}
