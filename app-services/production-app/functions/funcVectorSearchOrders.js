exports = async function(searchString) {

  const orders = context.services.get('mongodb-atlas').db('northwind').collection('orders');
  
  const searchVector = await context.functions.execute("funcVectorizeWithOpenAI", searchString);
  
  var pipeline = [
    { $search: {
      index: "vector_euclidean",
      knnBeta: {
        vector: searchVector,
        path: "embedding",
        k: 3,
      }
    }}
  ];

  return await orders.aggregate(pipeline).toArray()
  .then(data => {
    console.log(data.length);
    return data;
  })
  .catch(err => {
    console.log(err.toString());
    return err.toString();
  });
};