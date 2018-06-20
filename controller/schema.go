package controller

import (
	"fmt"
	"github.com/freeznet/tomato/storage/postgres"
	"github.com/freeznet/tomato/storage"
	"github.com/freeznet/tomato/types"
	"github.com/freeznet/tomato/orm"
	"github.com/go-ini/ini"
	"errors"
	"encoding/json"
)

func init(){
	schemaExtendInit()
	//
	//fmt.Println("------");
	//var e ExtendSchemaAPI;
	//e.getAllClass();
	//
	//orm.TomatoDBController.Update()
	//orm.Adapter.
	//
	//
	//fmt.Println("------");
	//
	//r,_ := e.getSpecificClass("GameScore");
	//r.printClassFieldInfo();
	//
	//fmt.Println("------");
	//
	//b,_ := e.getAllClassInJson();
	//
	//fmt.Println(string(b))
	//
	//b, _ = e.getSpecificClassInJson("GameScore")
	//
	//fmt.Println(string(b));



	//fmt.Println("------")
	//class := types.M{
	//	"fields" : types.M{
	//		"key": types.M{"type": "String"},
	//	},
	//}
	//className := "user";
	//
	//adap := postgres.NewPostgresAdapter("tomato", storage.OpenPostgreSQL());
	//
	//adap.DeleteClass(className);
	//
	//var classLevelPermissions types.M;
	//classLevelPermissions = nil;
	//
	//adap.CreateClass(className, class);
	//
	//obj := types.M{
	//	"key" : "adfasf",
	//}
	//orm.Adapter.CreateObject(className,class, obj);
	////orm.Adapter.AddFieldIfNotExists(className, "ccc", types.M{
	////	"type":"String",
	////	"ex":"sdfaas",
	////})
	//
	////newSchema := types.M{
	////			"type": "String",
	////			"subName": "cccc",
	////}
	//////
	//////
	//schema := orm.TomatoDBController.LoadSchema(nil);
	//
	//result, err := schema.UpdateClass(className, nil, classLevelPermissions);
	//fmt.Println(result);
	//fmt.Println(err);


	//
	//fmt.Println("------");
	//err = adap.UpdateFields(className, "key1", newSchema);
	//fmt.Println(err);
}


func TestAdd(){
	//r, e := orm.Adapter.GetClass("Alert");
	//
	//fmt.Println(e);
	//fmt.Println(r);
}


type ExtendSchemaAPI struct {

}

type ClassFieldInfo struct {
	ClassName string;
	Fields types.M;
	//classLevelPermissions types.M;
}


//get all class description under extend schema
func (e ExtendSchemaAPI) getAllClass() ([]ClassFieldInfo, error) {
	//return e.Adap.GetClass("SCHEMA_EXTEND1");
	result, err := orm.Adapter.Find("SCHEMA_EXTEND1", types.M{
		"fields": types.M{
			"className": types.M{"type": "String"},
			"schema": types.M{"type": "Object"},
			"isParseClass": types.M{"type": "Boolean"},
		},
	},nil, nil);

	var allClass = make([]ClassFieldInfo, len(result));
	for i:=0 ; i < len(result); i++{
		allClass[i] = ClassFieldInfo{
			ClassName: result[i]["className"].(string),
			Fields: result[i]["schema"].(types.M)["fields"].(map[string]interface {}),
		}

		allClass[i].printClassFieldInfo();
	}

	return allClass,err;
}

//get the class fields by name
func (e ExtendSchemaAPI) getSpecificClass(className string) (ClassFieldInfo, error) {
	result, _ := orm.Adapter.Find("SCHEMA_EXTEND1", types.M{
		"fields": types.M{
			"className": types.M{"type": "String"},
			"schema": types.M{"type": "Object"},
			"isParseClass": types.M{"type": "Boolean"},
		},
	},nil, nil);

	for i := 0 ; i < len(result); i++{
		//get the object for each things
		obj := result[i];

		if obj["className"] == className{
			return ClassFieldInfo{
				ClassName: result[i]["className"].(string),
				Fields: result[i]["schema"].(types.M)["fields"].(map[string]interface {}),
			}, nil;
		}

	}

	return ClassFieldInfo{}, errors.New("Cannot Find Class");
}

<<<<<<< HEAD
//for http request convert all class info into json
func (e ExtendSchemaAPI) getAllClassInJson()([]byte, error){
	allClass, err := e.getAllClass();
	if err != nil{
		return nil, err;
	}

	b,_ := json.Marshal(allClass);

	return b, nil;
}

//for http request convert specific class info into json
func (e ExtendSchemaAPI) getSpecificClassInJson(className string)([]byte, error){
	classInfo, err := e.getSpecificClass(className);
	if err != nil{
		return nil, err;
	}

	b,_ := json.Marshal(classInfo);
	return b, nil;
}
=======
>>>>>>> 0943b86c38eac4a2485c41c5e835f74abd31b890

func (c ClassFieldInfo) printClassFieldInfo(){
	fmt.Println("------");
	fmt.Println("Class Name:", c.ClassName);
	printMap(c.Fields);
}

//initialize the extended field
func schemaExtendInit(){
	fmt.Println("------");

	//create a new adapter for postgres
	Adap := postgres.NewPostgresAdapter("tomato", storage.OpenPostgreSQL());
	//delete class first
	Adap.DeleteClass("SCHEMA_EXTEND1");


	//set up the fields(columns) for extended schema
	ss := types.M{
		"fields": types.M{
			"className": types.M{"type": "String"},
			"schema": types.M{"type": "Object"},
			"isParseClass": types.M{"type": "Boolean"},
		},
	}

	//create the extended schema if it is not exist
	_, err := Adap.CreateClass("SCHEMA_EXTEND1", ss);
	fmt.Println(err);

	fmt.Println("------");


	//check if it exist
	if Adap.ClassExists("SCHEMA_EXTEND1"){
		fmt.Println("GET!");
	}else{
		fmt.Println("Fail");
	}

	//fetch the class
	result, _ := Adap.GetClass("SCHEMA_EXTEND1");

	fmt.Println(result);
	fmt.Println(err);


	fmt.Println("------");

	//get the schema data
	d := orm.TomatoDBController.LoadSchema(nil);

	schema,_ := d.GetAllClasses(nil);

	fmt.Println(len(schema));
	for i := 0; i < len(schema); i++{
		//forming the ini for specific class
		path := "./controller/extended_schema_configure/" + schema[i]["className"].(string) + ".ini";
		//fmt.Println(path);

		aa,err := ini.Load(path);
		//fmt.Println(err)
		//if there is external requirement
		if err == nil{
			fmt.Println(path);
			allSecs := aa.Sections();

			//add all external fields
			loadExFiels(allSecs, schema[i]);
		}


		printTypesM(schema[i]);
		//mark the class name, fields, insert object
		Adap.CreateObject("SCHEMA_EXTEND1", ss, types.M{
			"className": schema[i]["className"],
			"schema": schema[i],
			"isParseClass": schema[i]["isPaarseClass"],
		})

		//update into the _Schema
		Adap.UpdateFields(schema[i]["className"].(string), types.M{
			"className": schema[i]["className"],
			"schema": schema[i],
			"isParseClass": schema[i]["isPaarseClass"],
		})

		fmt.Println();
	}

	//close adapter
	Adap.HandleShutdown();
}

func loadExFiels(allSection []*ini.Section, input types.M){
	//looping all columns
	for i:=0; i < len(allSection); i++{
		allKeyVals := allSection[i].Keys();
		allKeyStr := allSection[i].KeyStrings();

		//looping all new fields
		for j:=0; j < len(allKeyStr); j++{
			fmt.Println(allKeyStr[j], allKeyVals[j]);
			//input[allSection[i].].(types.M)[targetField].(types.M)["subName"] = subName;
			addNewField(allSection[i].Name(), allKeyStr[j], allKeyVals[j].String(), input["fields"].(types.M));
		}
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
}

func addSubName(subName string, targetField string, field types.M)  {
	field["fields"].(types.M)[targetField].(types.M)["subName"] = subName;
	//fmt.Println(field["fields"].(types.M));
	fmt.Println(field["fields"].(types.M)[targetField])
}


//add new {newTypeName:newTypeVals} field to the specific column of schema
func addNewField(OriginCol string,newTypeName string, newTypeVals string, input types.M)  {
	//if user want to add the feature to the column which does not exist
	if input[OriginCol] == nil{
		panic("Column Does Not Exist!")
	}

	//then assign the values to the keys
	input[OriginCol].(types.M)[newTypeName] = newTypeVals;
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}