#!/bin/bash

function usage() {
    echo "Usage: $(basename "$0") [option...] {development|staging|production}" >&2
    echo
    echo "  Coding Garden Community App frontend deployment script"
    echo "  Deploys the frontend to the specified environment on now.sh"
    echo
    echo "   -h, --help                 Show this message"
    echo "   -n, --now-token            Specify the now token. (or set environment variable \$NOW_TOKEN)"
    echo "   -e, --node-env             Specify the node environemt. (or set environment variable \$NODE_ENV)"
    echo "   -a, --alias                Specify the deploy alias. (or set environment variable \$DEPLOY_ALIAS)"
    echo

    exit 1
}

while :
do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -n|--now-token)
      # TODO: validate input length and chars
      NOW_TOKEN="$2"
      shift 2
      ;;
    -e|--node-env)
      # TODO: validate input length and chars
      NODE_ENV="$2"
      shift 2
      ;;
    -a|--alias)
      # TODO: validate input length and chars
      DEPLOY_ALIAS="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      echo
      usage
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$NOW_TOKEN" ]; then
  echo "Error: NOW_TOKEN is not set via environment variable or as argument"
  echo
  usage
  exit 1
fi

if [ "$1" ]; then
  env=$1
elif [ -n "$TRAVIS_BRANCH" ]; then
  case "$TRAVIS_BRANCH" in
    develop)
      env=development
      ;;
    master)
      env=production
      ;;
    *)
      echo "Missing or invalid environment."
      usage
      exit 1
      ;;
  esac
fi

case "$env" in
  development)
    if [ -z "$NODE_ENV" ]; then
      NODE_ENV=development
    fi
    if [ -z "$DEPLOY_ALIAS" ]; then
      DEPLOY_ALIAS=web-dev.codinggarden.community
    fi
    ;;
  production)
    if [ -z "$NODE_ENV" ]; then
      NODE_ENV=production
    fi
    if [ -z "$DEPLOY_ALIAS" ]; then
      DEPLOY_ALIAS=codinggarden.community
    fi
    ;;
  *)
    echo "Missing or invalid environment."
    usage
    exit 1
    ;;
esac

if [ -z "$NOW_TOKEN" ]; then
  echo "Error: NOW_TOKEN is not set via environment variable or as argument"
  echo
  usage
  exit 1
fi

echo "Deploying to $env environment with alias $DEPLOY_ALIAS"

DEPLOYMENT_URL=$(npx now --token "$NOW_TOKEN" deploy -e NODE_ENV="$NODE_ENV")
npx now --token "$NOW_TOKEN" alias $DEPLOYMENT_URL $DEPLOY_ALIAS