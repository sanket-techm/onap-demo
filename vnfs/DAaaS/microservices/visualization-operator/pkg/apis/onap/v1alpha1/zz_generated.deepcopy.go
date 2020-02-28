// +build !ignore_autogenerated

// Code generated by operator-sdk. DO NOT EDIT.

package v1alpha1

import (
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *Datasource) DeepCopyInto(out *Datasource) {
	*out = *in
	if in.JsonData != nil {
		in, out := &in.JsonData, &out.JsonData
		*out = make(map[string]string, len(*in))
		for key, val := range *in {
			(*out)[key] = val
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new Datasource.
func (in *Datasource) DeepCopy() *Datasource {
	if in == nil {
		return nil
	}
	out := new(Datasource)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *GrafanaDataSource) DeepCopyInto(out *GrafanaDataSource) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	in.Spec.DeepCopyInto(&out.Spec)
	out.Status = in.Status
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new GrafanaDataSource.
func (in *GrafanaDataSource) DeepCopy() *GrafanaDataSource {
	if in == nil {
		return nil
	}
	out := new(GrafanaDataSource)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *GrafanaDataSource) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *GrafanaDataSourceList) DeepCopyInto(out *GrafanaDataSourceList) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	out.ListMeta = in.ListMeta
	if in.Items != nil {
		in, out := &in.Items, &out.Items
		*out = make([]GrafanaDataSource, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new GrafanaDataSourceList.
func (in *GrafanaDataSourceList) DeepCopy() *GrafanaDataSourceList {
	if in == nil {
		return nil
	}
	out := new(GrafanaDataSourceList)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *GrafanaDataSourceList) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *GrafanaDataSourceSpec) DeepCopyInto(out *GrafanaDataSourceSpec) {
	*out = *in
	if in.Datasources != nil {
		in, out := &in.Datasources, &out.Datasources
		*out = make([]Datasource, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
	if in.Grafana != nil {
		in, out := &in.Grafana, &out.Grafana
		*out = make(map[string]string, len(*in))
		for key, val := range *in {
			(*out)[key] = val
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new GrafanaDataSourceSpec.
func (in *GrafanaDataSourceSpec) DeepCopy() *GrafanaDataSourceSpec {
	if in == nil {
		return nil
	}
	out := new(GrafanaDataSourceSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *GrafanaDataSourceStatus) DeepCopyInto(out *GrafanaDataSourceStatus) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new GrafanaDataSourceStatus.
func (in *GrafanaDataSourceStatus) DeepCopy() *GrafanaDataSourceStatus {
	if in == nil {
		return nil
	}
	out := new(GrafanaDataSourceStatus)
	in.DeepCopyInto(out)
	return out
}