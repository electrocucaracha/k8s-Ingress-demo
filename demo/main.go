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
	"errors"
	"fmt"
	"net/http"
	"os"
	"time"
)

func indexHandler(w http.ResponseWriter, _ *http.Request) {
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
	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadTimeout:       5 * time.Second,
		ReadHeaderTimeout: 5 * time.Second,
		WriteTimeout:      10 * time.Second,
	}
	err := srv.ListenAndServe()
	if errors.Is(err, http.ErrServerClosed) {
		fmt.Printf("server closed\n")
	} else if err != nil {
		fmt.Printf("error starting server: %s\n", err)
		os.Exit(1)
	}
}
