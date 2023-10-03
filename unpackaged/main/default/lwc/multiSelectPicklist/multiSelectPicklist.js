import { LightningElement, wire, track, api } from 'lwc';

export default class MultiSelectPicklist extends LightningElement {
    @api showLabel;
    label;
    @api optionslist = [];
    @api selectedoptions = [];
    _selectedValues;
    @api get selectedValues() {
        return this._selectedValues;
    }
    set selectedValues(val) {
        this._selectedValues = val;
        if (val) {
            this.selectedoptions = val.split(';');
        }
    }
    @api label;
    @api index;
    @api fieldName;
    @api isRequired;
    processBlur = false;
    @track valid = true;
    @track roleOptions;
    get selectedvaluelength() {
        return this.label ? this.selectedoptions.length + ' ' + this.label + ' Selected' : this.selectedoptions.length + ' Values Selected';
    }
    connectedCallback() {
        let options = [];
        for (let i = 0; i < this.optionslist.length; i++) {
            let opt = JSON.parse(JSON.stringify(this.optionslist[i]));
            if (this.selectedoptions.indexOf(this.optionslist[i].value) != -1) {
                opt.selected = true;
            } else {
                opt.selected = false;
            }
            options.push(opt);
        }
        this.optionslist = JSON.parse(JSON.stringify(options));
        window.addEventListener('click', this.handleWindowClick);

    }
    handleWindowClick = (event) => {
        //console.log('this.template::',this.template);
        if (this.processBlur) this.template.querySelector('.optionList').classList.add('slds-hide');
    }

    disconnectedCallback() {
        window.addEventListener('click', this.handleWindowClick);
    }
    showList(event) {
        if (this.template.querySelector('.optionList').className.indexOf('slds-hide') != -1) {
            this.template.querySelector('.optionList').classList.remove('slds-hide');
        } else {
            this.template.querySelector('.optionList').classList.add('slds-hide');
            const scrollEvent = new CustomEvent('selecting', { detail: { selectedoptions: this.selectedoptions, index: this.index, fieldName: this.fieldName } });
            this.dispatchEvent(scrollEvent);
        }
    }
    handleMouseEnter() {
        this.processBlur = false;
    }

    handleMouseLeave() {
        this.processBlur = true;
    }
    hideList(event) {
        if (this.processBlur) {
            this.template.querySelector('.optionList').classList.add('slds-hide');
            const scrollEvent = new CustomEvent('selecting', { detail: { selectedoptions: this.selectedoptions, index: this.index, fieldName: this.fieldName } });
            this.dispatchEvent(scrollEvent);
        }

    }
    selectOption(event) {
        let targetId = parseInt(event.currentTarget.dataset.targetId);
        let selectedopt = JSON.parse(JSON.stringify(this.selectedoptions));
        let options = JSON.parse(JSON.stringify(this.optionslist));
        options[targetId].selected = !(options[targetId].selected);
        this.optionslist = JSON.parse(JSON.stringify(options));
        if (options[targetId].selected) {
            if (selectedopt.indexOf(options[targetId].value) == -1) {
                selectedopt.push(options[targetId].value);
            }
        } else {
            if (selectedopt.indexOf(options[targetId].value) != -1) {
                selectedopt.splice(selectedopt.indexOf(options[targetId].value), 1);
            }
        }
        this.selectedoptions = selectedopt;
        const scrollEvent = new CustomEvent('selecting', { detail: { selectedoptions: this.selectedoptions, index: this.index, fieldName: this.fieldName } });
        this.dispatchEvent(scrollEvent);
        if (this.selectedoptions && this.selectedoptions.length > 0) {
            this.valid = true;
            let input = this.template.querySelector('.selectinput')
            if (input.className.indexOf('errorinput') != -1) {
                input.classList.remove('errorinput');
            }
            if (input.className.indexOf('successinput') == -1) {
                input.classList.add('successinput');
            }
        }
    }
    @api
    isValid() {
        let valid = false;
        if (this.selectedoptions && this.selectedoptions.length > 0) {
            valid = true;
        }
        let input = this.template.querySelector('.selectinput')

        if (valid) {
            if (input.className.indexOf('errorinput') != -1) {
                input.classList.remove('errorinput');
            }
            if (input.className.indexOf('successinput') == -1) {
                input.classList.add('successinput');
            }
            /*if(input.className.indexOf('slds-has-error') != -1){
                input.classList.remove('slds-has-error');
            }*/
            this.valid = true;
        } else {
            if (input.className.indexOf('errorinput') == -1) {
                input.classList.add('errorinput');
            }
            if (input.className.indexOf('successinput') != -1) {
                input.classList.remove('successinput');
            }
            this.valid = false;
        }
        return valid;
    }
    @api clearValues() {
        this.selectedoptions = [];
        let options = JSON.parse(JSON.stringify(this.optionslist));
        options.forEach(option => {
            option.selected = false;
        });
        this.optionslist = options;
    }
}