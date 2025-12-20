import { GlueClient, StartJobRunCommand } from "@aws-sdk/client-glue";

export const handler = async (event) => {
  const jobName = process.env.JOB_NAME;

  if (!jobName) {
    console.error("JOB_NAME environment variable is not set.");
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Job name is required." }),
    };
  }

  const client = new GlueClient({});
  const command = new StartJobRunCommand({ JobName: jobName });

  try {
    await client.send(command);
    console.log(`Successfully started Glue job: ${jobName}`);
    return {
      statusCode: 200,
      body: JSON.stringify({ message: `Job ${jobName} started.` }),
    };
  } catch (error) {
    console.error("Error starting Glue job:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Failed to start job.",
        error: error.message,
      }),
    };
  }
};
