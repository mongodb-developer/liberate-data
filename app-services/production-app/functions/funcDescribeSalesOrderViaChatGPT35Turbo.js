exports = async function(salesOrder) {
  
    const openai_prompt = `From the Sales Order json object below, In 5 or more sentences, describe what the sales order is about.
                            The description should include aspects like items in the sales order, quantity and discount: 
                            \n${JSON.stringify(salesOrder)}\n\n`;
    
    const openai_url ='https://api.openai.com/v1/chat/completions';
    
    const openai_key = context.values.get("openAI_value");

    try {
        console.log("Prompt: " + openai_prompt);

        let response = await context.http.post({
            url: openai_url,
             headers: {
                'Authorization': [`Bearer ${openai_key}`],
                'Content-Type': ['application/json']
            },
            body: JSON.stringify({
              "model": "gpt-3.5-turbo",
              "messages": [{"role": "user", "content": openai_prompt}],
              "temperature": 0.7
            })
        });
        
        let responseData = EJSON.parse(response.body.text());
        
        if(response.statusCode === 200) {
            console.log("Successfully received description.");
            console.log(JSON.stringify(responseData));

            const description = responseData.choices[0].message.content;
            console.log(description);
            return description;

        } else {
            console.log(`Failed to receive embedding. Status code: ${response.statusCode}`);
        }

    } catch(err) {
        console.error(err);
    }
};