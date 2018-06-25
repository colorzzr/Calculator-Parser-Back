package main

import (
	"github.com/freeznet/tomato"
	"github.com/freeznet/tomato/config"
	"fmt"
	"hdswitch-backend/controller"
)

func main() {
	controller.Init();
	tomato.Run()
	//beego.Run();
}


func initLiveQueryServer() {
	args := map[string]string{}
	args["pattern"] = "/livequery"
	args["addr"] = ":8089"
	args["logLevel"] = "VERBOSE"
	args["serverURL"] = "http://127.0.0.1:8080/v1"
	args["appId"] = config.TConfig.AppID
	args["clientKey"] = config.TConfig.ClientKey
	args["masterKey"] = config.TConfig.MasterKey
	args["keyPairs"] = fmt.Sprintf("{\"javascriptKey\":\"%s\"}", config.TConfig.JavaScriptKey)
	args["subType"] = "EventEmitter"
	go tomato.RunLiveQueryServer(args)
}
