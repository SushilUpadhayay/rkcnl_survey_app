const fs = require('fs');
const pdf = require('pdf-parse');

const pdfPath = '../Requirements Specification For RKCNL(1)(1).pdf';
let dataBuffer = fs.readFileSync(pdfPath);

pdf(dataBuffer).then(function(data) {
    fs.writeFileSync('../parsed_requirements.txt', data.text);
    console.log('PDF parsed and saved to ../parsed_requirements.txt');
}).catch(function(error){
    console.error(error);
});
