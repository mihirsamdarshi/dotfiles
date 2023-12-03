function newvenv -d "Shorthand for creating a new virtualenv"
  argparse --name=newvenv 'h/help' 'd/directory' 'r/requirements=!test -f "$_flag_value"' -- $argv
  or return

  if set -q _flag_directory
    set venv_dir "$_flag_directory"
  else
    set venv_dir "venv"
  end

  python3 -m venv $venv_dir
  source $venv_dir/bin/activate.fish
  pip install --upgrade pip setuptools wheel

  if set -q _flag_requirements
    pip install -r "$_flag_requirements"
  else
    echo "No requirements file provided. You can specify one using -r or --requirements."
  end
end

complete -c newvenv -s h -l help -d "Show help message"
complete -c newvenv -s d -l directory -d "Name of the directory for the new virtual environment"
complete -c newvenv -s r -l requirements -d "Path to requirements file for pip installation"


