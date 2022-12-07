const fs = require('fs');
const html = fs.readFileSync('index.html', { encoding:'utf8' });
const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();
/**
 * Returns an HTML page containing an interactive Web-based
 * tutorial. Visit the function URL to see it and learn how
 * to build with lambda.
 */
exports.handler = async (event) => {
    if(event.queryStringParameters){
        const tablePut = await dynamo.put({
            TableName: "formStore",
            Item: {
              PK: "form",
              SK: event.requestContext.requestId,
              form: event.queryStringParameters
            }
        }).promise();
    }
    let modifiedHTML = dynamicForm(html,event.queryStringParameters)
    
    let params = {
      TableName: "formStore",
      KeyConditionExpression: "PK = :PK",
      ExpressionAttributeValues: {
        ":PK": "form"
          }
    }
    const tableQuery = await  dynamo.query(params, function(err, data) {
           if (err) console.log(err);
           else console.log(data);
        }).promise()      
        
    modifiedHTML = dynamictable(modifiedHTML,tableQuery)
    
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'text/html',
            },
            body: modifiedHTML,
        };
        return response;
    };

function dynamicForm(html,queryStringParameters){
    let formres = ''
    if(queryStringParameters){
            Object.values(queryStringParameters).forEach(val => {
                  formres =formres+val+' ';
            });
    }
    return html.replace('{formResults}','<h4>Form Submission: '+formres+'</h4>')
}
function dynamictable(html,tableQuery){
    let table=""
        if(tableQuery.Items.length>0){
         for (let i = 0; i < tableQuery.Items.length; i++) {
              table = table+"<li>"+JSON.stringify(tableQuery.Items[i])+"</li>"
            } 
           table= "<pre>"+table+"</pre>"
        }
        return html.replace("{table}","<h4>DynamoDB:</h4>"+table)
}