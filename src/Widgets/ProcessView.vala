


namespace elementarySystemMonitor {

    /**
     * What columns are expected for a TreeView/TreeModel for Processes
     */
    public enum ProcessColumns {
        ICON,
        NAME,
        PID,
        CPU,
        MEMORY,
        NUM_COLUMNS
    }

    public class ProcessView : Gtk.TreeView {
        private Gtk.TreeViewColumn name_column;
        private Gtk.TreeViewColumn cpu_column;
        private Gtk.TreeViewColumn memory_column;

        /**
         * Constructs a new ProcessView
         */
        public ProcessView () {
            rules_hint = true;

            // setup name column
            name_column = new Gtk.TreeViewColumn ();
            name_column.title = _("Application/Process Name");
            name_column.fixed_width = 300;
            name_column.max_width = 300;

            var icon_cell = new Gtk.CellRendererPixbuf ();
            name_column.pack_start (icon_cell, false);
            name_column.add_attribute (icon_cell, "icon_name", ProcessColumns.ICON);

            var name_cell = new Gtk.CellRendererText ();
            name_column.pack_start (name_cell, false);
            name_column.add_attribute (name_cell, "text", ProcessColumns.NAME);

            insert_column (name_column, -1);

            // setup cpu column
            var cpu_cell = new Gtk.CellRendererText ();
            cpu_cell.xalign = 0.5f;
            cpu_column = new Gtk.TreeViewColumn.with_attributes (_("CPU (%)"), cpu_cell);
            cpu_column.set_cell_data_func (cpu_cell, cpu_usage_cell_layout);
            cpu_column.alignment = 0.5f;
            insert_column (cpu_column, -1);

            // setup memory column
            var memory_cell = new Gtk.CellRendererText ();
            memory_cell.xalign = 0.5f;
            memory_column = new Gtk.TreeViewColumn.with_attributes (_("Memory Usage"), memory_cell);
            cpu_column.set_cell_data_func (memory_cell, memory_usage_cell_layout);
            memory_column.alignment = 0.5f;
            insert_column (memory_column, -1);

            // resize all of the columns
            columns_autosize ();
        }


        public void cpu_usage_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            // grab the value that was store in the model and convert it down to a usable format
            Value cpu_usage_value;
            model.get_value (iter, ProcessColumns.CPU, out cpu_usage_value);
            double cpu_usage = cpu_usage_value.get_double ();

            // format the double into a string
            if (cpu_usage < 0.0)
                (cell as Gtk.CellRendererText).text = "-";
            else
                (cell as Gtk.CellRendererText).text = "%.0f%%".printf (cpu_usage * 100.0);
        }

        public void memory_usage_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
            // grab the value that was store in the model and convert it down to a usable format
            Value memory_usage_value;
            model.get_value (iter, ProcessColumns.MEMORY, out memory_usage_value);
            int64 memory_usage = memory_usage_value.get_int64 ();
            double memory_usage_double = (double) memory_usage;
            string units = _("KiB");

            // convert to MiB if needed
            if (memory_usage_double > 1024.0) {
                memory_usage_double /= 1024.0; 
                units = _("MiB");
            }
            
            // convert to GiB if needed
            if (memory_usage_double > 1024.0) {
                memory_usage_double /= 1024.0; 
                units = _("GiB");
            }

            // format the double into a string
            if (memory_usage == 0)
                (cell as Gtk.CellRendererText).text = "-";
            else
                (cell as Gtk.CellRendererText).text = "%.1f %s".printf (memory_usage_double, units);
        }
    }
}
