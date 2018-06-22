package controller

import (
	"fmt"
	"github.com/freeznet/tomato/types"
	"github.com/freeznet/tomato/orm"
	"github.com/go-ini/ini"
	"errors"
	"encoding/json"
	"github.com/freeznet/tomato/utils"
	"log"
)

func Init(){
	SchemaExtendInit();
}

func makeCopyOfSchema(){
	//set up the fields(columns) for extended schema
	ss := types.M{
		"fields": types.M{
			"className": types.M{"type": "String"},
			"schema": types.M{"type": "String"},
		},
	}
	//create the extended schema if it is not exist
	orm.Adapter.CreateClass("SchemaExtend", ss);

	//get the schema data
	d := orm.TomatoDBController.LoadSchema(nil);
	schema,_ := d.GetAllClasses(nil);

	for i := 0; i < len(schema); i++{
		b, _ := json.Marshal(schema[i]);
		//mark the class name, fields, insert object
		fmt.Println(orm.Adapter.CreateObject("SchemaExtend", ss, types.M{
			"className": schema[i]["className"],
			"schemaExtend": string(b),
		}));
	}
}

//initialize the extended field
func SchemaExtendInit(){
	fmt.Println("------");
	fmt.Println("Initial the SchemaExtend...");
	//get the schema data
	d := orm.TomatoDBController.LoadSchema(nil);

	//looping through all existing
	schema,_ := d.GetAllClasses(nil);
	for i := 0; i < len(schema); i++{
		//forming the ini path for specific class
		path := "./controller/extended_schema_configure/" + schema[i]["className"].(string) + ".ini";

		iniFile,err := ini.Load(path);
		//if there is external requirement
		if err == nil{
			fmt.Println(path);
			allSecs := iniFile.Sections();

			//add all external fields
			loadExFiels(allSecs, schema[i]["fields"].(types.M));

			//printTypesM(schema[i]);
			//update into the _Schema
			err = orm.Adapter.UpdateFields(schema[i]["className"].(string), schema[i]);
			if err != nil{
				log.Println(err);
			}
		}
	}
	fmt.Println("-------");
}

//function loading all section inside ini file and add new field type
func loadExFiels(allSection []*ini.Section, input types.M) {
	//looping all columns
	for i:=0; i < len(allSection); i++{
		if allSection[i].Name() == "DEFAULT"{continue;}

		allKeyVals := allSection[i].Keys();
		allKeyStr := allSection[i].KeyStrings();

		/********************************************************
		 * create new map for overwrite original one			*
		 * cos if user remove the newfield in the .ini file		*
		 * but new schema would still have it					*
		 ********************************************************/
		//if user want to add the feature to the column which does not exist
		if input[allSection[i].Name()] == nil{
			panic(errors.New("Column " + allSection[i].Name() + " Does Not Exist!"));

		}
		emptyMap := types.M{
			"type" : utils.M(input[allSection[i].Name()])["type"],
		}
		input[allSection[i].Name()] = emptyMap;
		fmt.Println(input);
		//looping all new fields
		for j:=0; j < len(allKeyStr); j++{
			err := addNewField(allSection[i].Name(), allKeyStr[j], allKeyVals[j].String(), input);
			checkErr(err);
		}
		fmt.Println();
	}
}

func printMap (input map[string]interface{}){
	for k,v := range input{
		fmt.Println(k,"=", v);
	}
}

func printTypesM(input types.M)  {
	fmt.Println(input["fields"]);
	fmt.Println(input["className"]);
	fmt.Println(input["classLevelPermissions"]);
	fmt.Println();
}

//add new {newTypeName:newTypeVals} field to the specific column of schema
func addNewField(OriginCol string, newTypeName string, newTypeVals string, input types.M) error {
	//cannot modify the default column
	if OriginCol == "objectId" ||OriginCol == "ACL" ||OriginCol == "createdAt" ||OriginCol == "updatedAt"{
		return errors.New(OriginCol + "is Default Column Cannot Modify");
	}else if newTypeName == "type" {
		return errors.New("Cannot Modify the property 'type'");
	}

	//then assign the values to the keys
	temp := utils.M(input[OriginCol]);
	temp[newTypeName] = newTypeVals;
	return nil;
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}