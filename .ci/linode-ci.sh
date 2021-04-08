#!/usr/bin/env bash
#
# ci-linode-up
#
# Create a new Linode for CI purposes.
#

readonly BASE_DIR="$( cd "${BASH_SOURCE[0]%/*}/.." && pwd )"

# shellcheck source=../lib/utils.sh
. "${BASE_DIR}/lib/utils.sh"

BRANCH="${GITHUB_REF:-${GIT_BRANCH_NAME:-main}}"
PASSWORD="${LINODE_ROOT_PASSWORD:-}"
LINODE_LABEL_BASE="ci-dots-${BRANCH}"
LINODE_IMAGE_LABEL="${LINODE_IMAGE_LABEL:-linode/debian10}"
LINODE_LABEL="${LINODE_LABEL_BASE}--${LINODE_IMAGE_LABEL}"
LINODE_LABEL="$(string::sanitize "${LINODE_LABEL}")"


# Get a field from a Linode resource.
# Parameters:
#   Resource type (singular)
#   Resource label
#   Field key
function .get_field() {
  local type=$1
  local label="$2"
  local key="$3"
  linode-cli "${type}s" list \
    --format="${key}" \
    --label="${label}" \
    --no-headers \
    --text
}

# Whether a linode with the specified label is rebuilding.
# Parameters:
#   Linode label
function is_rebuilding() {
  local loabel=$1
  [[ "rebuilding" == $(.get_field linode "${label}" status) ]]
}

# Whether a linode with the specified label is running.
# Parameters:
#   Linode label
function is_running() {
  local label=$1
  [[ "running" == $(.get_field linode "${label}" status) ]]
}

# Print a human-friendly table of info about the specified linode.
# Parameters:
#   Linode label
function print_linode_info() {
  local label=$1
  linode-cli linodes list --label="${label}"
}

# Initialize a rebuild of the specified linode from an image.
# Parameters:
#   Linode label
#   Source image label
#   Root password
function init_rebuild() {
  local linode_label=$1
  local image_label=$2
  local pass=$3

  print_linode_info "${linode_label}"

  print_warning "The CI linode will be destroyed and rebuilt!"

  if ! is_ci; then
    ask_for_confirmation "Do you want to continue?"

    if ! user_confirmed; then
      print_error "Cancelled!" "Exiting..."
      return 1
    fi
  fi

  id=$(.get_field linode "${linode_label}" id)
  image=$(.get_field image "${image_label}" id)

  linode-cli linodes rebuild "${id}" \
    --image="${image}" \
    --root_pass="${pass}"
  print_result $? "Initiated linode rebuild"
}

# Monitor the rebuild status of the specified linode.
# Parameters:
#   Linode label
function check_status() {
  local label=$1
  local pause=10

  until is_rebuilding "${label}"; do
    [[ pause -eq 0 ]] && {
      print_error "[Error]" "Status check timed out. Aborting."
      print_warning "You may want to verify the status manually."
      return 1
    }

    # The Linode CLI doesn't appear to report the linode's "rebuilding" status
    # immediately, so decrease the wait time in an attempt to catch the change
    # in status.
    execute "sleep ${pause}" "Waiting for 'rebuilding' status (${pause}s)" \
      && pause=$(( pause - 2 ))
  done

  print_warning "Linode is rebuilding!"

  pause=10
  until is_running "${label}"; do
    execute "sleep ${pause}" "Waiting for 'running' status..."
  done

  print_success "Linode '${label}' is running!"
}

function create() {
  local label=$1

  if [[ -n "${label}" ]]; then
    if is_ci && [[ "${label}" != "ci-dots-"* ]]; then
      print_error "[ERROR] Linode label '${label}' does not begin with 'ci-dots-'. Aborting."
      return 1
    fi

    # @TODO validate label name
    # see constraints in docs for "label"
    # https://www.linode.com/docs/api/linode-instances/#linode-create

  else
    print_error "[ERROR] You need to specify a source image in order to create a new linode! Aborting."
    return 1
  fi

  [[ -z "${LINODE_IMAGE}" ]] && {
    print_error "[ERROR] You need to specify a source image in order to create a new linode! Aborting."
    return 1
  }

  # @TODO validate image name
  # @TODO what does the linode-cli do if an invalid image name is passed?

  [[ -z "${PASSWORD}" ]] && {
    print_error "[ERROR] Linode root password not specified! Aborting."
    return 1
  }

  exit

  linode-cli linodes create \
    --type=g6-nanode-1 \
    --region=us-east \
    --backups_enabled=false \
    --image="${LINODE_IMAGE}" \
    --root_pass="${PASSWORD}" \
    --booted=true \
    --label="${label}" \
    --tags=ci --tags=github-actions
}

function destroy() {
  local label=$1
  local id
  id="$(.get_field linode "${label}" id)"
  linode-cli linodes destroy "${id}"
}

function rebuild() {
  local label

  if is_rebuilding "${label}"; then
    print_linode_info "${label}"
    print_warning "The linode '${label}' is already rebuilding!" "Aborting."
    return 1
  else
    if [[ -z "${PASSWORD}" ]]; then
      if is_ci; then
        print_error "Root password is not set! Aborting."
        return 1
      fi
      set_password_global
    fi

    init_rebuild \
      "${label}" \
      "${LINODE_IMAGE_LABEL}" \
      "${PASSWORD}"
  fi

  check_status "${label}"
  print_linode_info "${label}"
}

function main() {
  local action="$1"
  local label="${2:-LINODE_LABEL}"

  [[ -z "${action}" ]] && {
    print_error "No action specified! Aborting."
    return 1
  }

  if ! cmd_exists "linode-cli"; then
    print_error "[Error]" "linode-cli not found!"
    return 1
  fi

  case $action in
    create) create "${label}" ;;
    destroy) destroy "${label}" ;;
    rebuild) rebuild "${label}" ;;
    *)
      print_error "Invalid action '${action}' passed! Aborting."
      return 1 ;;
  esac

}

main "$@"
