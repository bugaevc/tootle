using Gtk;

public class Tootle.Views.TabbedBase : Views.Base {

	static int ID_COUNTER = 0;

	protected Adw.ViewSwitcherTitle switcher_title;
	protected Adw.ViewSwitcherBar switcher_bar;
	protected Adw.ViewStack stack;

	Views.Base? last_view = null;

	construct {
		state = "content";

		(states.get_parent () as Box).remove (states);
		view.get_style_context ().remove_class ("ttl-view");
		(scrolled.get_parent () as Box).remove (scrolled);
		insert_child_after (states, header);

		stack = new Adw.ViewStack ();
		stack.notify["visible-child"].connect (on_view_switched);
		content_box.append (stack);

		switcher_bar.stack = switcher_title.stack = stack;
	}

	public override void build_header () {
		switcher_title = new Adw.ViewSwitcherTitle ();
		bind_property ("label", switcher_title, "title", BindingFlags.SYNC_CREATE);
		// header.bind_property ("subtitle", switcher_title, "subtitle", BindingFlags.SYNC_CREATE);
		header.title_widget = switcher_title;

		switcher_bar = new Adw.ViewSwitcherBar ();
		switcher_title.bind_property ("title-visible", switcher_bar, "reveal", BindingFlags.SYNC_CREATE);
		append (switcher_bar);
	}

	public void add_tab (Views.Base view) {
		ID_COUNTER++;
		var page = stack.add_titled (view, ID_COUNTER.to_string (), view.label);
		view.bind_property ("icon", page, "icon-name", BindingFlags.SYNC_CREATE);
		view.bind_property ("needs-attention", page, "needs-attention", BindingFlags.SYNC_CREATE);
		view.header.hide ();
	}

	public Views.Base add_list_tab (string label, string icon) {
		var tab = new Views.ContentBase ();
		tab.label = label;
		tab.icon = icon;

		add_tab (tab);

		return tab;
	}

	public delegate void TabCB (Views.ContentBase tab);
	public void foreach_tab (TabCB cb) {
		for (var w = stack.get_first_child (); w != null; w = w.get_next_sibling ()) {
			var tab = w as Views.ContentBase;
			if (tab != null)
				cb (tab);
		}
	}

	public override void clear () {
		foreach_tab (tab => tab.clear ());
		on_content_changed ();
	}

	// TODO: Why did I write this? What does it do??? Why does it crash????
	public override void on_content_changed () {
		// var empty = true;
		foreach_tab (tab => {
			// tab.visible = !tab.empty;
			// if (tab.visible)
			// 	empty = false;

			tab.on_content_changed ();
		});
		state = "content";

		// if (empty) {
		// 	state = "status";
		// 	status_message = STATUS_EMPTY;
		// }
		// else {
		// 	state = "content";
		// }
	}

	void on_view_switched () {
		var view = stack.visible_child as Views.Base;

		if (last_view != null) {
			last_view.current = false;
			last_view.on_hidden ();
		}

		if (view != null) {
			label = view.label;
			view.current = true;
			view.on_shown ();
		}

		last_view = view;
	}

}
