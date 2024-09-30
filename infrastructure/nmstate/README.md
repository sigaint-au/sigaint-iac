# Node Network Configuration

The following labels need to be applied (example):

* `sigaint.au/physnet="eno4"`
* `sigaint.au/physnet="eno2"`

Each machine should have one set as well as the following labels.

* `sigaint.au/hardware="dell"`
* `sigaint.au/hardware="lenovo"`

The policy you create in the overlays should match the labels.