.PHONY: watch compile live

ifeq ($(OS),Windows_NT)
    watch:
		@PowerShell -Command "typst watch template/template.typ --root . Abdullah_Al_Khalid_CV.pdf"

    compile:
		@PowerShell -Command "typst compile --root . template/template.typ Abdullah_Al_Khalid_CV.pdf"

    live:
		@PowerShell -Command "python serve.py 8080"
else
    watch:
		@bash -c "typst watch --root . template/template.typ Abdullah_Al_Khalid_CV.pdf"

    compile:
		@bash -c "typst compile --root . template/template.typ Abdullah_Al_Khalid_CV.pdf"

    live:
		@bash -c "python3 serve.py 8080"
endif
