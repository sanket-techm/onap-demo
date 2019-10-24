package controller

import (
	"prometheus-remote-config-operator/pkg/controller/prometheusremoteendpoint"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, prometheusremoteendpoint.Add)
}
