.PHONY: watch compile

ifeq ($(OS),Windows_NT)
    watch:
		@PowerShell -Command "typst watch template/template.typ --root . Abdullah_Al_Khalid_CV.pdf"

    compile:
		@PowerShell -Command "typst compile --root . template/template.typ Abdullah_Al_Khalid_CV.pdf"
else
    watch:
		@bash -c "typst watch --root . template/template.typ Abdullah_Al_Khalid_CV.pdf"

    compile:
		@bash -c "typst compile --root . template/template.typ Abdullah_Al_Khalid_CV.pdf"
endif
