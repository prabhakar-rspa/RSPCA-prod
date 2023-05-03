	jQuery(function() {
        $('.disabledInput').prop('disabled', true);
    });
	/*$(function() {
    var previous = $("#datatable").text();
	$check = function() {
		debugger;
		if ($("#datatable").text() != previous) {
			if(selectAllCheckbox) {
				$('#parentCheck').prop('checked', true);
				selectaAllChild();
			} else {
				$('#parentCheck').prop('checked', false);
				selectParent();
			}
		}
		previous = $("#datatable").text();
	}
	setInterval(function() { $check(); }, 1);
	});*/
    
    function selectParent() {
        if($('input.childCheck[type=checkbox]').length > 0) {
            if ($('input.childCheck[type=checkbox]:not(:checked)').length){
                $("#parentCheck").removeAttr('checked');
                selectAllCheckbox = false;
            } else {
                $("#parentCheck").prop('checked',true);
                selectAllCheckbox = true;
            }
        }
    }
    
    function selectaAllChild() {
        if($('#parentCheck').is(':checked')) {
           $(".childCheck").prop('checked', true);
           selectAllCheckbox = true;
        } else {
           $(".childCheck").prop('checked', false);
           selectAllCheckbox = false;
        }
    }
	
    function search() {
        selectAllCheckbox = $('#parentCheck').is(':checked');
        $("[id*='inputFilterJSON']").val(document.getElementById("hiddenFilters").value);
        $("[id*='opportunityId']").val(document.getElementById("oppID").value);
        $("[id*='pricebookId']").val(document.getElementById("pricebookId").value);
        var inputFilter = document.getElementById("inputLogicFilter").value;
		if(inputFilter === '') {
			inputFilter = "1";
		}
		var result = inputFilter.replace(/\b(\d+)\b/g, '{$1}');
		$("[id*='filterLogic']").val(result);
		if(angular.element(document.getElementById('mainWrap')).scope().validateFilters()) {
			applyFilters();
		}
		selectParent();
    }
    var myapp = angular.module('AddProduct', []);
    var contrl = myapp.controller('AddProductCtrl', function ($scope, $filter) {
        document.getElementById("TypeMessage").className ="";
		$scope.showRemoveFilterButton = false;
        $scope.AllFieldAggregate;
        $scope.Filters = [];
        $scope.Filters.push({
            Id: 0,
            Field: {
                value: "",
                label: "",
                sfdcLabel: ""
            },
            Operator: "",
            Value: "",
            OperatorOptions: [],
            LineNr: "1"
        });
        $scope.Products = [];
        $scope.oppID = '{!$CurrentPage.parameters.recordId}';
        $scope.pageNumber = 1;
        $scope.filterCondition = "";
        $scope.pricebookId = '{!pricebookId}';
		Visualforce.remoting.Manager.invokeAction(prefix.substring(0, prefix.length - 2) + '.AddProductController.getProductFields', function(result, event){
                $scope.$apply(function() {
                    var data = result.replace(/(&quot\;)/g,"\"");
                    $scope.AllFieldAggregate=JSON.parse(data);
                    $scope.Filters[0].Field = $scope.AllFieldAggregate[0];
                    $scope.Filters[0].Operator = 'NONE';
                });
            });
        $scope.switchOperator = function(fieldType) {
            fieldType.OperatorOptions = [];
            $scope.Filters[fieldType.Id].Operator = 'NONE';
            switch (fieldType.Field.value) {
                case 'ID':
                case 'STRING':
                case 'TEXTAREA':
                case 'REFERENCE':
                case 'PICKLIST':
                    fieldType.OperatorOptions.push(
                        {value: "equals", label: "equals"},
                        {value: "not equal to", label: "not equals to"},
                        {value: "contains", label: "contains"},
                        {value: "does not contain", label: "does not contain"},
                        {value: "starts with", label: "starts with"}
                    );
                    break;
                case 'BOOLEAN':
                    fieldType.OperatorOptions.push(
                        {value: "equals", label: "equals"},
                        {value: "not equal to", label: "not equals to"}
                    );
                    break;
                case 'DATE':
                case 'DATETIME':
                case 'DOUBLE':
                case 'INTEGER':
                case 'CURRENCY':
                    fieldType.OperatorOptions.push(
                        {value: "equals", label: "equals"},
                        {value: "not equal to", label: "not equals to"},
                        {value: "less than", label: "less than"},
                        {value: "greater than", label: "greater than"},
                        {value: "less or equal", label: "less or equal"},
                        {value: "greater or equal", label: "greater or equal"}
                    );
                    break;
                default:
                    //console.log(fieldType.Field.value);
            }
        };
        $scope.AddFilter=function(item) {
			var filterSize = $scope.Filters.length;
            if (filterSize > 4) {
				document.getElementById("ErrorMessage").innerHTML = 'You have reached the maximum number of 5 criteria rows.';
                document.getElementById("TypeMessage").className = "slds-notify slds-notify--alert slds-theme--error slds-theme--alert-texture";
                return;
            }
			$scope.showRemoveFilterButton = true;
            $scope.Filters.push({
                Field: {
                    value: "",
                    label: "",
                    sfdcLabel: ""
                },
                Id: $scope.Filters.length,
                Operator: "",
                Value: "",
                OperatorOptions: [],
                LineNr: ""
            });
            $scope.Filters[filterSize].Field = $scope.AllFieldAggregate[0];
            $scope.Filters[filterSize].Operator = 'NONE';
			$scope.Filters[filterSize - 1].LineNr = filterSize + '.';
            $scope.Filters[filterSize].LineNr = filterSize + 1 + '.';
			if(filterSize == 1) {
				$("#inputLogicFilter").val(filterSize + ' AND ' + Number(filterSize + 1));
			} else {
				$("#inputLogicFilter").val($("#inputLogicFilter").val() + ' AND ' + Number(filterSize + 1));
			}
        };
		$scope.removeFilter=function(item) {
			$scope.Filters.splice(item, 1);
			document.getElementById("ErrorMessage").innerHTML = '';
            document.getElementById("TypeMessage").className = '';
			if($scope.Filters.length < 2) {
				$scope.showRemoveFilterButton = false;
			}
			var logicFilterValue = '';
			for(var i=0;i<$scope.Filters.length;i++) {
				$scope.Filters[i].Id = i;
				$scope.Filters[i].LineNr = i + 1;
				logicFilterValue +=  i + 1;
				if(i != $scope.Filters.length -1) {
					logicFilterValue += ' AND ';
				}
			}
			$("#inputLogicFilter").val(logicFilterValue);
		};
		
        $scope.validateFilters = function() {
            for(var i=0; i<$scope.Filters.length; i++) {
                if (!$scope.validateDecimal($scope.Filters[i])) return false;
                if (!$scope.validateBoolean ($scope.Filters[i])) return false;
            }
			if(!$scope.validateLogicFilter()) return false;
			return true;
        };
		$scope.validateLogicFilter = function() {
			var logicFilterValue = $("#inputLogicFilter").val();
			var booleanPattern = /^(?!(^\s?(AND|OR)\s?.*)|(.*\s?(AND|OR)\s?$))((\([1-5](((\s(AND|OR)\s[1-5]))+)\))|(\s(AND|OR)\s[1-5])|([1-5]\s(AND|OR)\s)|(\s(AND|OR)\s)|\s?[1-5]\s?)+$/;
			var bPatternRegExp = new RegExp(booleanPattern).test(logicFilterValue);
			
			if($scope.Filters.length > 1 && logicFilterValue.length < 1) {
				var error = 'Please fill the Filter Logic';
                document.getElementById("ErrorMessage").innerHTML = error;
                document.getElementById("TypeMessage").className = "slds-notify slds-notify--alert slds-theme--error slds-theme--alert-texture";
                return false;
			} else if(logicFilterValue.length > 0 && !bPatternRegExp) {
				var error = 'Invalid Filter Logic value, please enter as (1 AND 2) OR 3';
                document.getElementById("ErrorMessage").innerHTML = error;
                document.getElementById("TypeMessage").className = "slds-notify slds-notify--alert slds-theme--error slds-theme--alert-texture";
                return false;
			} else {
				document.getElementById("ErrorMessage").innerHTML = "";
                document.getElementById("TypeMessage").className ="";
			}
			return true;
		};
        $scope.validateBoolean = function(item) {
            var booleanPattern = /(false|true)$/;
            var bPatternRegExp = new RegExp(booleanPattern).test(item.Value);
            if (item.Field.value == 'BOOLEAN' && !bPatternRegExp) {
                var error = 'Error: ' + item.Field.sfdcLabel + ' - Invalid field (Valid field format true/false).';
                document.getElementById("ErrorMessage").innerHTML = error;
                document.getElementById("TypeMessage").className = "slds-notify slds-notify--alert slds-theme--error slds-theme--alert-texture";
                return false;
            } else {
				document.getElementById("ErrorMessage").innerHTML = "";
                document.getElementById("TypeMessage").className ="";
            }
            
            return true;
        };
        /*$scope.validateDate = function(item) {
		    document.getElementById("ErrorMessage").innerHTML = "";
			document.getElementById("TypeMessage").className ="";
            return true;
        };*/
        $scope.validateDecimal = function(item) {
            var decimalPattern = /^[0-9]\d*(\.\d+)?$/;
            if (item.Value != ''  && (item.Field.value == 'DOUBLE' || item.Field.value == 'INTEGER' || item.Field.value == 'CURRENCY')) {
                if (!item.Value.match(decimalPattern)) {
					var error = 'Error: ' + item.Field.sfdcLabel + ' - Invalid field (Valid field format 1 or 1.0)';
					document.getElementById("ErrorMessage").innerHTML = error;
                    document.getElementById("TypeMessage").className = "slds-notify slds-notify--alert slds-theme--error slds-theme--alert-texture";
                    return false;
                } else {
                    $scope.ErrorMessage = "";
                    document.getElementById("TypeMessage").className ="";
                }
            }
            return true;
        };
    });