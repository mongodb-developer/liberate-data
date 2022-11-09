exports = async function(searchString) {

  const orders = context.services.get('mongodb-atlas').db('northwind').collection('orders');
  
  var pipeline = [
    // orders
    {
     $search: {
      text: {
       query: searchString,
       path: [
        'employee.notes',
        'orderDetails.product.productName',
        'orderDetails.product.quantityPerUnit'
       ],
       fuzzy: {
        maxEdits: 1,
        prefixLength: 1,
        maxExpansions: 256
       }
      }
     }
    }, {
     $unionWith: {
      coll: 'categories',
      pipeline: [
           {
            $search: {
             text: {
              query: searchString,
              path: [
               'categoryName',
               'description'
              ],
              fuzzy: {
               maxEdits: 1,
               prefixLength: 1,
               maxExpansions: 256
              }
             }
            }
           },
           {
            $lookup: {
             from: 'orders',
             localField: '_id',
             foreignField: 'orderDetails.product.categoryId',
             as: 'result'
            }
           },
           {
            $project: {
             _id: 0,
             result: 1
            }
           },
           {
            $unwind: '$result'
           }
      ]
     }
    }
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