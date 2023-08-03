exports = async function(changeEvent) {
    const doc = changeEvent.fullDocument;

    try {
        console.log(`Processing document with id: ${doc._id}`);

        const embedding = await context.functions.execute("funcVectorizeWithOpenAI", doc.string);
        
        if (embedding.length > 0) {
        
            const mongodb = context.services.get('mongodb-atlas');
            const db = mongodb.db('northwind'); 
            const collection = db.collection('vectorizedStrings'); 

            const result = await collection.updateOne(
                { _id: doc._id },
                { $set: { 
                  vector: embedding, 
                }}
            );

            if(result.modifiedCount === 1) {
                console.log("Successfully updated the document.");
            } else {
                console.log("Failed to update the document.");
            }
        } else {
            console.log(`Failed to receive embedding. Status code: ${response.statusCode}`);
        }

    } catch(err) {
        console.error(err);
    }
};