<?php

/**
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 * Copyright (c) 2021 Universitäts- und Landesbibliothek Sachsen-Anhalt
 * @class ULBThemePlugin
 *
 */
import('lib.pkp.classes.plugins.ThemePlugin');

class ULBThemePlugin extends ThemePlugin {
	/**
	 * Initialize the theme's styles, scripts and hooks. This is only run for
	 * the currently active theme.
	 */

	public function isActive() {
		if (defined('SESSION_DISABLE_INIT')) return true;
		return parent::isActive();
	}
	 public function init() {
		$request = Application::get()->getRequest();
		$this->setParent('defaultthemeplugin');
		$this->modifyStyle('stylesheet', array('addLess' => array('styles/ulb.less')));
        $this->addScript('default', 'js/ulb.js');
		// TODO: vielleich kann man sich so das Anlegen eins Menues ersparen 
		//$this->addMenuArea(array('primary', 'user'));
	}

	function getDisplayName() {
		return __('plugins.themes.ulb_theme.name');
	}

	function getDescription() {
		return __('plugins.themes.ulb_theme.description');
	}
}

?>
