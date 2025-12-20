import { GlueClient, StartCrawlerCommand } from "@aws-sdk/client-glue";

export const handler = async (event) => {
  const crawlerName = process.env.CRAWLER_NAME;

  if (!crawlerName) {
    console.error("CRAWLER_NAME environment variable is not set.");
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Crawler name is required." }),
    };
  }

  const client = new GlueClient({});
  const command = new StartCrawlerCommand({ Name: crawlerName });

  try {
    await client.send(command);
    console.log(`Successfully started Glue crawler: ${crawlerName}`);
    return {
      statusCode: 200,
      body: JSON.stringify({ message: `Crawler ${crawlerName} started.` }),
    };
  } catch (error) {
    console.error("Error starting Glue crawler:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Failed to start crawler.",
        error: error.message,
      }),
    };
  }
};
