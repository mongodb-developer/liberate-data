exports = async function(stringToVectorize) {

    const openai_url = 'https://api.openai.com/v1/embeddings';
    
    const openai_key = context.values.get("openAI_value");

    try {
        console.log("Vectorizing: " + stringToVectorize);

        let response = await context.http.post({
            url: openai_url,
             headers: {
                'Authorization': [`Bearer ${openai_key}`],
                'Content-Type': ['application/json']
            },
            body: JSON.stringify({
                input: stringToVectorize,
                model: "text-embedding-ada-002"
            })
        });
        
        let responseData = EJSON.parse(response.body.text());
        
        if(response.statusCode === 200) {
            console.log("Successfully received embedding.");

            const embedding = responseData.data[0].embedding;
            
            console.log(JSON.stringify(embedding));

            return embedding;

        } else {
            console.log(`Failed to receive embedding. Status code: ${response.statusCode}`);
        }

    } catch(err) {
        console.error(err);
    }
};