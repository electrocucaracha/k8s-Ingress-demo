/*
Copyright 2020
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"fmt"
	"net/http"
	"os"
)

func indexHandler(w http.ResponseWriter, r *http.Request) {
	name, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	switch locale := os.Getenv("LOCALE"); {
	case locale == "es":
		_, err = w.Write([]byte("<h1>Hola CNCF El Salvador desde <b>" + name + "</b> nodo</h1>"))
	default:
		_, err = w.Write([]byte("<h1>Hello CNCF El Salvador from <b>" + name + "</b> node</h1>"))
	}
	if err != nil {
		panic(err)
	}
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	mux := http.NewServeMux()

	fmt.Println("Starting server at " + port)
	mux.HandleFunc("/", indexHandler)
	err := http.ListenAndServe(":"+port, mux)
	if err != nil {
		panic("Error: " + err.Error())
	}
}
