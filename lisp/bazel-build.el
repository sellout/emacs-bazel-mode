;;; bazel-build.el --- Emacs utilities for using Bazel -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2018 Google LLC
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;      http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;
;;; Commentary:
;;
;; This package provides commands to build and run code using Bazel.
;; It defines interactive commands which perform completion of available Bazel
;; targets:
;;   - `bazel-build'
;;   - `bazel-run'
;;   - `bazel-test'
;;
;;; Code:

(require 'bazel-util)

(defgroup bazel-build nil
  "Tooling for building Bazel projects."
  :link '(url-link "https://github.com/bazelbuild/emacs-bazel-mode")
  :group 'bazel)

(defcustom bazel-command "bazel"
  "Filename of bazel executable."
  :type 'string
  :group 'bazel-build)

(defun bazel-build (target)
  "Build a Bazel TARGET."
  (interactive (list (bazel-build--read-target (concat bazel-command " build "))))
  (bazel-build--run-bazel-command "build" target))

(defun bazel-run (target)
  "Build and run a Bazel TARGET."
  (interactive (list (bazel-build--read-target (concat bazel-command " run "))))
  (bazel-build--run-bazel-command "run" target))

(defun bazel-test (target)
  "Build and run a Bazel test TARGET."
  (interactive (list (bazel-build--read-target (concat bazel-command " test "))))
  (bazel-build--run-bazel-command "test" target))

(defun bazel-build--run-bazel-command (command target)
  "Run Bazel tool with given COMMAND, e.g. build or run, on the given TARGET."
  (compile
   (mapconcat #'shell-quote-argument (list bazel-command command target) " ")))

(defun bazel-build--read-target (prompt)
  "Read a Bazel build target from the minibuffer.  PROMPT is a read-only prompt."
  (let* ((file-name (or (buffer-file-name) default-directory))
         (workspace-root
          (or (bazel-workspace-root file-name)
              (user-error "Not in a Bazel workspace.  No WORKSPACE file found")))
         (package-name
          (or (bazel-package-name file-name workspace-root)
              (user-error "Not in a Bazel package.  No BUILD file found")))
         (initial-input (concat "//" package-name)))
    (read-string prompt initial-input)))

(provide 'bazel-build)

;;; bazel-build.el ends here
