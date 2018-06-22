package controller

import (
	"testing"
	"github.com/freeznet/tomato/types"
	"reflect"
	"qiniupkg.com/x/errors.v7"
	"os"
	"github.com/go-ini/ini"
	"github.com/freeznet/tomato/storage/postgres"
	"github.com/freeznet/tomato/storage"
	"fmt"
)

func Test_addNewField(t *testing.T){
	err := addNewField("Exist", "Exist", "Exist", types.M{"Exist":types.M{"type":"dsaf"}});
	if err != nil{
		t.Error("Fail");
	}

	err = addNewField("objectId", "default", "default", types.M{"objectId":types.M{"type":"sdaf"}});
	if !reflect.DeepEqual(err, errors.New("objectId" + "is Default Column Cannot Modify")){
		t.Error("Fail");
	}

	err = addNewField("type", "type", "type", types.M{"type":types.M{"type":"sdaf"}});
	if !reflect.DeepEqual(err, errors.New("Cannot Modify the property 'type'")){
		t.Error("Fail", err);
	}


	t.Log("Finish")
}

func Test_ExSchemaInit(t *testing.T){
	//create the test.ini
	os.Create("./test.ini");
	testIni,_ := ini.Load("./test.ini");
	sec,_ :=testIni.NewSection("Name");
	sec.NewKey("SubName", "ccc");


	//create a new adapter for postgres
	Adap := postgres.NewPostgresAdapter("tomato", storage.OpenPostgreSQL());

	fmt.Println("------");

	ss := types.M{
		"fields": types.M{
			"Name": types.M{"type": "String"},
		},
	}
	Adap.CreateClass("testClass", ss);

	allSecs := testIni.Sections();
	//add all external fields
	schema,_:= Adap.GetClass("testClass");
	loadExFiels(allSecs, schema["fields"].(types.M));

	err := Adap.UpdateFields("testClass", schema);
	if err != nil{
		t.Error(err);
	}

	Adap.DeleteClass("testClass");
	os.Remove("./test.ini");
	//close adapter
	Adap.HandleShutdown();
	t.Log("Finish");
}