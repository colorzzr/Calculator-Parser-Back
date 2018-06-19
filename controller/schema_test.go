package controller

import "testing"

func Test_getAllClass_EASY(t *testing.T){
	var e ExtendSchemaAPI;
	_,err := e.getAllClass();

	if err != nil{
		t.Error(err);
	}else{
		t.Log("Pass");
	}
}

func Test_getSpecificClass_EASY_1(t *testing.T){
	var e ExtendSchemaAPI;
	r,err := e.getSpecificClass("_Role");
	r.printClassFieldInfo();

	if err != nil{
		t.Error(err);
	}else{
		t.Log("Pass");
	}
}

func Test_getSpecificClass_EASY_2(t *testing.T){
	var e ExtendSchemaAPI;
	_,err := e.getSpecificClass("WRONGGG");
	//r.printClassFieldInfo();

	if err == nil{
		t.Error("Class Should Not Exit");
	}else{
		t.Log("Pass,", err.Error());
	}
}