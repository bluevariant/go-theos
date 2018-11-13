package main

//#include "./main.h"
import "C"

import (
  "fmt"
  "unsafe"
)

//export ExportMainObjectiveC
func ExportMainObjectiveC(argc C.int, argv, envp **C.char) C.int {
  args := goStrings(argc, argv)
  fmt.Println(args)
  fmt.Println("Hi alpine!")
  return 0
}

func goStrings(argc C.int, argv **C.char) []string {
  length := int(argc)
  tmpSlice := (*[1 << 9]*C.char)(unsafe.Pointer(argv))[:length:length]
  goStrings := make([]string, length)
  for i, s := range tmpSlice {
    goStrings[i] = C.GoString(s)
  }
  return goStrings
}

func main() {}
