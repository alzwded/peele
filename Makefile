DISTNAME = peele-0.9
DEPS = \
./Core/DBEngine.pm \
./Core/Document.pm \
./Core/ExpressionEngine.pm \
./Core/PluginManager.pm \
./help.html \
./LICENSE \
./peele.pl \
./Plugins/Cleaner.pm \
./Plugins/HxxScanner.pm \
./Plugins/MinMax.pm \
./Plugins/Select.pm \
./Plugins/SQLiteDB.pm \
./Plugins/XCorrel.pm \
./README.md \
./sql/schema.sql \
./UI/ChainEditor.pm \
./UI/Components/FieldEditor.pm \
./UI/Components/ListEditor.pm \
./UI/Components/PluginConfig.pm \
./UI/Components/ProgressMonitor.pm \
./UI/DBPicker.pm \
./UI/HelpAbout.pm \
./UI/PeeleApplication.pm \
./UI/PluginSettings.pm \
./UI/ResultsDisplay.pm \


$(DISTNAME).txz: $(DEPS)
	mkdir -p dist
	tar cv $(DEPS) | tar xv -C dist/
	mv dist $(DISTNAME)
	tar cJvf $(DISTNAME).txz $(DEPS)
	mv $(DISTNAME) dist

clean:
	rm -rf dist $(DISTNAME).txz
