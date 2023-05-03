	$( document ).ready(function() {
		$("a.slds-input").removeClass("slds-input");
		$(".removeNoneValue option[value='']").remove();
		$('.disabledInput').prop('disabled', true);
		
		for(i=0;i<rowNumber;i++) {
            viewBillingMethod(i);
			hideOrShowRenewalBillingTemplate(i);
			hideOrShowProrate(i);
			hideOrShowBillingFrequency(i);
			setAmountLabel(i);
        }
		
		$( ".errorMsg" ).each(function() {
            $(".slds-is-expanded").each(function() {
                $(this).removeClass('slds-is-expanded').addClass('slds-is-collapsed');
                $('.' + this.id).html('&#9658;');
            });
            return false;
        });

        $( ".errorMsg" ).each(function() {
            $(this).closest("ul").removeClass('slds-is-collapsed');
            $(this).closest("ul").addClass('slds-is-expanded');
            $('.' + $(this).closest("ul.slds-is-expanded").attr('Id')).html('&#9660;');
        });
	});
	
	function hideOrShowRenewalBillingTemplate(rowCount) {
        if($(".renew-" + rowCount).is(':checked')) {
            $(".renewalBillingTemplate-" + rowCount).css("display","");
        } else {
            $(".renewalBillingTemplate-" + rowCount).css("display","none");
        }
    }
	
	function hideOrShowProrate(row) {
		if(($(".billingMethod" + row).val() == 'Fixed price' && $(".fixedAmount" + row).val() == 'Include with every invoice') || 
		($(".billingMethod" + row).val() == 'Quantity based' && $(".fixedAmount" + row).val() == 'Include with every invoice' && $(".quantityTypeField" + row).val() == 'Variable')) {
			$(".prorate" + row).css("display","");
			
		} else {
			$(".prorate" + row).css("display","none");
		}
	}

	function hideOrShowBillingFrequency(row) {
		if(($(".billingMethod" + row).val() == 'Fixed price' && $(".fixedAmount" + row).val() == 'Include with every invoice') || 
		($(".billingMethod" + row).val() == 'Quantity based' && $(".fixedAmount" + row).val() == 'Include with every invoice' && $(".quantityTypeField" + row).val() == 'Variable')) {
			$(".billingFrequency" + row).css("display","");
		} else {
			$(".billingFrequency" + row).css("display","none");
		}
	}
	
	function viewQuantityType(row) {
		if($(".quantityTypeField" + row).val() == 'Variable') {
			$(".quantityTypeCommitted" + row).css("display", "");
			$(".quantityTypeCommitted" + row).css("display", "");
			$(".quantityTypeShow" + row).css("display", "none");
			$(".quantityTypeShow" + row).css("display", "none");
			$(".flatFixedAmount" + row).css("display","");
			$(".quantityTypeVariable" + row).css("display","");
		}
		if($(".quantityTypeField" + row).val() == 'Committed') {
			$(".quantityTypeCommitted" + row).css("display", "none");
			$(".quantityTypeCommitted" + row).css("display", "none");
			$(".quantityTypeShow" + row).css("display", "");
			$(".quantityTypeShow" + row).css("display", "");
			$(".flatFixedAmount" + row).css("display","none");
		}

		hideOrShowBillingFrequency(row);
		hideOrShowProrate(row);
		enableOrDisableAmount(row);
		viewFixedAmount(row);
	}

	function setAmountLabel(row) {
		if($(".billingMethod" + row).val() == 'Fixed price') {
			$("#amountLabel" + row).text("*OR Enter Flat/fixed amount");
		} else {
			$("#amountLabel" + row).text("*Flat/fixed amount");
		}	
	}

	function enableOrDisableAmount(row) {
		if($(".billingMethod" + row).val() == 'Quantity based' &&  $(".quantityTypeField" + row).val() == 'Committed') {
			$(".base-amount" + row).addClass("disabledAmount");	
		} else {
			$(".base-amount" + row).removeClass("disabledAmount");
		}
	}

	function viewBillingMethod(row) {		
        if($(".billingMethod" + row).val() == 'Quantity based') {
            $(".fixedPrice" + row).css("display","none");
            $(".quantityBased" + row).css("display","");
            $(".flatFixedAmount" + row).css("display","");
            $(".base-amount" + row).css("display","");
            $(".base-amountEmptyField" + row).css("display","none");
            viewFixedAmount(row);
			viewQuantityType(row)
        }
        if($(".billingMethod" + row).val() == 'Fixed price') {
            $(".fixedPrice" + row).css("display","");
            $(".quantityBased" + row).css("display","none");
            $(".flatFixedAmount" + row).css("display","");
            $(".base-amount" + row).css("display","");
            $(".base-amountEmptyField" + row).css("display","none");
            viewFixedAmount(row);
        }
        if($(".billingMethod" + row).val() == 'Project time & materials' || $(".billingMethod" + row).val() == 'Project T&M') {
            $(".fixedPrice" + row).css("display","none");
            $(".quantityBased" + row).css("display","none");
            $(".billingTemplate" + row).css("display","none");
            $(".flatFixedAmount" + row).css("display","none");
            $(".base-amount" + row).css("display","none");
            $(".base-amountEmptyField" + row).css("display","");
        }
		hideOrShowProrate(row);
		hideOrShowBillingFrequency(row);
		enableOrDisableAmount(row);
		setAmountLabel(row);
    }
	
    function viewFixedAmount(row) {
        if($(".fixedAmount" + row).val() == 'One-time' || ($(".fixedAmount" + row).val() == 'Include with every invoice') || ($(".quantityTypeField" + row).val() == 'Committed')) {
            $(".billingTemplate" + row).css("display","none");
        } else {
            $(".billingTemplate" + row).css("display","");
        }
		hideOrShowProrate(row);
		hideOrShowBillingFrequency(row);
    }
	
    function expandLine(obj,obj1) {
        var colapseClass = document.getElementsByClassName("slds-is-expanded");
        if(colapseClass != null) {
            for(var i = 0; i < colapseClass.length; ++i) {
                colapseClass[i].className = 'slds-is-collapsed';
            }
        }
        var el = document.getElementById(obj);                                       
        if ( el.className != 'slds-is-collapsed' ) {
            el.className = 'slds-is-collapsed';
        } else {
            el.className = 'slds-is-expanded';
        }
        
        var chevronClass = document.getElementsByClassName("chevron");
        if(chevronClass != null) {
            for(var i = 0; i < chevronClass.length; ++i) {
                chevronClass[i].innerHTML = '&#9658;';
            }
        }
        
        var e2 = document.getElementById(obj1); 
        if ( e2.innerHTML != '&#9658;' ) {
            e2.innerHTML = '&#9660;';
        }
    }	