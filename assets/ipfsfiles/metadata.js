const fs = require('fs');
const path = require('path');



// {
// 	"name": "Asset Name",
// 	"description": "Lorem ipsum...",
// 	"image": "https:\/\/s3.amazonaws.com\/your-bucket\/images\/{id}.png",
// 	"properties": {
// 		"simple_property": "example value",
// 		"rich_property": {
// 			"name": "Name",
// 			"value": "123",
// 			"display_value": "123 Example Value",
// 			"class": "emphasis",
// 			"css": {
// 				"color": "#ffffff",
// 				"font-weight": "bold",
// 				"text-decoration": "underline"
// 			}
// 		},
// 		"array_property": {
// 			"name": "Name",
// 			"value": [1,2,3,4],
// 			"class": "emphasis"
// 		}
// 	}
// }

const objects = [];
const maxCardTokenId = 4;
const fragmentCountPerCard = 4;
const maxId = maxCardTokenId + maxCardTokenId * fragmentCountPerCard;
const imageFolderCid = 'QmcBbmi6bR8sVvrYMRond1bRFiNsntCW3z7qndJheLhxMA';
for (let i = 0; i < maxId; i++) {
    const isCard = i < maxCardTokenId;
    const name = isCard ? `Card ${i+1}` : `Card ${Math.floor(i / maxCardTokenId)} Fragment ${i % maxCardTokenId + 1}`;
    console.log(name);
    const obj = {
        name: name,
        image: `ipfs://${imageFolderCid}/${i+1}.png`,
        properties: {
            type: isCard ? 'card': 'fragment',
            parent: isCard ? (i + 1) : Math.floor(i / maxCardTokenId),
            level: (1 === (i+1) || 1 === Math.floor(i / maxCardTokenId)) ? 'high' : 'low'
        }
    };
    objects.push(obj);
    console.log(JSON.stringify(obj));
}


// 指定保存.json文件的文件夹路径
const outputDir = './BlindBoxNFT1_metadatas';

// 确保输出文件夹存在
if (!fs.existsSync(outputDir)){
    fs.mkdirSync(outputDir);
}

// 遍历对象数组，序列化并保存为.json文件
objects.forEach((obj, index) => {
    const fileName = `${index + 1}.json`;
    const filePath = path.join(outputDir, fileName);
    const jsonString = JSON.stringify(obj);

    fs.writeFile(filePath, jsonString, (err) => {
        if (err) {
            console.error(`Error writing file ${filePath}:`, err);
        } else {
            console.log(`File ${filePath} saved successfully.`);
        }
    });
});