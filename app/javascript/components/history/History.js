import React from 'react';
import { PropTypes } from 'prop-types';
import { Button, Card } from 'react-bootstrap';
import axios from 'axios';
import reportError from '../util/ReportError';
import moment from 'moment-timezone';

import { formatTimestamp } from '../../utils/DateTime';
import moment from 'moment-timezone';
import { time_ago_in_words } from './helpers';

class History extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      edit_mode: false,
      loading: false,
      comment: '',
    };
  }

  handleEditComment = () => {
    this.setState({ edit_mode: true });
  };

  handleTextChange = event => {
    this.setState({ comment: event.target.value });
  };

  handleDeleteComment = () => {
    this.setState({ loading: true }, () => {
      axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
      axios
        .delete(window.BASE_PATH + '/histories/' + this.props.history.id)
        .then(() => {
          location.reload(true);
        })
        .catch(error => {
          reportError(error);
        });
    });
  };

  formatEditable = () => {
    if (this.props.history.history_type == 'Comment') {
      return (
        <React.Fragment>
          <Button variant="link" id={this.props.history.id} className="py-0" onClick={this.handleEditComment}>
            Edit
          </Button>
          <Button variant="link" id={this.props.history.id} className="py-0" onClick={this.handleDeleteComment}>
            Delete
          </Button>
        </React.Fragment>
      );
    } else {
      return '';
    }
  };

  editComment = () => {
    this.setState({ loading: true }, () => {
      axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
      axios
        .patch(window.BASE_PATH + '/histories/' + this.props.history.id, {
          comment: this.state.comment,
        })
        .then(() => {
          location.reload(true);
        })
        .catch(error => {
          reportError(error);
        });
    });
  };

  renderEditMode = () => {
    if (this.state.edit_mode == true) {
      return (
        <Card.Body>
          <textarea
            id="comment"
            name="comment"
            className="form-control"
            style={{ resize: 'none' }}
            rows="3"
            placeholder={this.props.history.comment}
            value={this.state.comment}
            onChange={this.handleTextChange}
          />
          <button className="mt-3 btn btn-primary btn-square float-right" disabled={this.state.loading || this.state.comment === ''} onClick={this.editComment}>
            <i className="fas fa-comment-dots"></i> Edit Comment
          </button>
        </Card.Body>
      );
    } else {
      return (
        <Card.Body>
          <Card.Text>{this.props.history.comment}</Card.Text>
        </Card.Body>
      );
    }
  };

  render() {
    return (
      <React.Fragment>
        <Card className="card-square mt-4 mx-3 shadow-sm">
          <Card.Header>
            <b>{this.props.history.created_by}</b>, {time_ago_in_words(moment(this.props.history.created_at).toDate())} ago (
            {moment
              .tz(this.props.history.created_at, 'UTC')
              .tz(moment.tz.guess())
              .format('YYYY-MM-DD HH:mm z')}
            )
            <span className="float-right">
              <div className="badge-padding h5">
                <span className="badge badge-secondary">{this.props.history.history_type}</span>
              </div>
              {this.formatEditable()}
            </span>
          </Card.Header>
          {this.renderEditMode()}
        </Card>
      </React.Fragment>
    );
  }
}
History.propTypes = {
  history: PropTypes.object,
  authenticity_token: PropTypes.string,
};

export default History;
