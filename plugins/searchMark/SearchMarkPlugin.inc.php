<?php

/**
 *
 * inspired by Brian Suda http://suda.co.uk/projects/SEHL/
 * Copyright (c) 2021 Universitäts- und Landesbibliothek Sachsen-Anhalt 
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 */

import('lib.pkp.classes.plugins.GenericPlugin');

class SearchMarkPlugin extends GenericPlugin {

	public function register($category, $path, $mainContextId = NULL) {
		$success = parent::register($category, $path);
		if ($success && $this->getEnabled()) {
			HookRegistry::register('TemplateManager::display', array($this, 'displayTemplateCallback'));
		}
		return $success;
    }

	public function displayTemplateCallback($hookName, $args) {
		$templateMgr =& $args[0];
		$template =& $args[1];
		$request = Application::get()->getRequest();
		if ($template != 'frontend/pages/article.tpl') return false;
		$queryarray = $request->getQueryArray();
		foreach($queryarray as $key => $value) {
			if ($key == 'query') {
				$querywords = explode(' ', $value);
			}
		  }
		$this->querywords = $querywords;
		$path = $request->getBaseUrl() . '/' . $this->getPluginPath() . '/highlight.css';
		$templateMgr->addStylesheet('highlightcss', $path);
		$templateMgr->registerFilter('output', array(&$this, 'outputFilter'));
		return false;
	}


	public function outputFilter($output, &$smarty) {
		$fromDiv = strstr($output, '<body');
		if ($fromDiv === false) return $output;
		
		$content = strpos($fromDiv, '>')  + 1;
		$startIndex = strlen($output) - strlen($fromDiv) + $content;
		$scanPart = substr($output, $startIndex);
	
		foreach ($this->querywords as $q) {	
			$newOutput = '';
			$pat = '/((<[^!][\/]*?[^<>]*?>)([^<]*))|<!---->|<!--(.*?)-->|((<!--[ \r\n\t]*?)(.*?)[ \r\n\t]*?-->([^<]*))/si';
			preg_match_all($pat, $scanPart, $tag_matches);
			
			for ($i=0; $i<count($tag_matches[0]); $i++) {
				if (
					(preg_match('/<!/i', $tag_matches[0][$i])) ||
					(preg_match('/<textarea/i', $tag_matches[2][$i])) ||
					(preg_match('/<script/i', $tag_matches[2][$i]))
				) {
					$newOutput .= $tag_matches[0][$i];
				} else {
					$newOutput .= $tag_matches[2][$i];
					$holder = preg_replace('/(.*?)(\W)('.preg_quote($q,'/').')(\W)(.*?)/iu',"\$1\$2<span class=\"sehl\">\$3</span>\$4\$5",' '.$tag_matches[3][$i].' ');
					$newOutput .= substr($holder,1,(strlen($holder)-2));
				}
			}
			$scanPart = $newOutput;
		}
		if(strlen($newOutput) > 0) {
			return (substr($output, 0, $startIndex) . $newOutput);
		}
		else{
			return $output;
		}
	}

	public function getDisplayName() {
		return __('plugins.generic.search.name');
	}

	public function getDescription() {
		return __('plugins.generic.search.description');
	}

	public function isSitePlugin() {
		return !Application::get()->getRequest()->getContext();  
	}

}