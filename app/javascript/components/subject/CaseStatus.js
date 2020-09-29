import React from 'react';
import { PropTypes } from 'prop-types';
import { Button, Modal, Form } from 'react-bootstrap';
import _ from 'lodash';
import axios from 'axios';

import InfoTooltip from '../util/InfoTooltip';
import reportError from '../util/ReportError';

class CaseStatus extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      showCaseStatusModal: false,
      confirmedOrProbable: this.props.patient.case_status === 'Confirmed' || this.props.patient.case_status === 'Probable',
      case_status: this.props.patient.case_status || '',
      isolation: this.props.patient.isolation,
      monitoring: this.props.patient.monitoring,
      monitoring_reason: this.props.patient.monitoring_reason,
      monitoring_option: '',
      apply_to_group: false,
      loading: false,
    };
    this.origState = Object.assign({}, this.state);
  }

  handleChange = event => {
    event.persist();
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

    if (event?.target?.name && event.target.name === 'apply_to_group') {
      let applyToGroup = event.target.id === 'apply_to_group_yes';
      this.setState({ [event.target.name]: applyToGroup });
    } else {
      this.setState({ [event.target.id]: value }, () => {
        if (event.target.id === 'case_status') {
          const confirmedOrProbable = value === 'Confirmed' || value === 'Probable';
          const hideModal = this.state.isolation && confirmedOrProbable && this.props.patient.case_status !== '';

          this.setState({ showCaseStatusModal: !hideModal, confirmedOrProbable }, () => {
            // specific case where case status is just changed with no modal
            if (hideModal) {
              this.submit();
            }
            if (!confirmedOrProbable && this.state.case_status !== '') {
              this.setState({ isolation: false });
            }
          });
        } else if (event.target.id === 'monitoring_option') {
          if (event.target.value === 'End Monitoring') {
            this.setState({
              isolation: this.props.patient.isolation,
              monitoring: false,
              monitoring_reason: 'Meets Case Definition',
            });
          }
          if (event.target.value === 'Continue Monitoring in Isolation Workflow') {
            this.setState({
              isolation: true,
              monitoring: true,
              monitoring_reason: 'Meets Case Definition',
            });
          }
        }
      });
    }
  };

  toggleCaseStatusModal = () => {
    let current = this.state.showCaseStatusModal;
    this.setState({
      showCaseStatusModal: !current,
      apply_to_group: false,
      case_status: this.props.patient.case_status || '',
      isolation: this.props.patient.isolation,
      monitoring: this.props.patient.monitoring,
      monitoring_reason: this.props.patient.monitoring_reason,
      monitoring_option: '',
    });
  };

  submit = () => {
    let diffState = Object.keys(this.state).filter(k => _.get(this.state, k) !== _.get(this.origState, k));
    this.setState({ loading: true }, () => {
      axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
      axios
        .post(window.BASE_PATH + '/patients/' + this.props.patient.id + '/status', {
          case_status: this.state.case_status,
          isolation: this.state.isolation,
          monitoring: this.state.monitoring,
          monitoring_reason: this.state.monitoring_reason,
          apply_to_group: this.state.apply_to_group,
          diffState: diffState,
        })
        .then(() => {
          location.reload(true);
        })
        .catch(error => {
          reportError(error);
        });
    });
  };

  renderRadioButtons() {
    return (
      <React.Fragment>
        <p className="mt-3 mb-2">Please select the records that you would like to apply this change to:</p>
        <Form.Group className="px-4">
          <Form.Check
            type="radio"
            className="mb-1"
            name="apply_to_group"
            id="apply_to_group_no"
            label="This monitoree only"
            onChange={this.handleChange}
            checked={!this.state.apply_to_group}
          />
          <Form.Check
            type="radio"
            className="mb-3"
            name="apply_to_group"
            id="apply_to_group_yes"
            label="This monitoree and all household members"
            onChange={this.handleChange}
            checked={this.state.apply_to_group}
          />
        </Form.Group>
      </React.Fragment>
    );
  }

  createModal(title, toggle, submit) {
    if (!this.props.patient.monitoring) {
      return (
        <Modal size="lg" show centered onHide={toggle}>
          <Modal.Header>
            <Modal.Title>{title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <p>
              Are you sure you want to change case status from {this.props.patient.case_status} to {this.state.case_status}? Since this record is on the Closed
              line list, updating this value will not move this record to another line list. If this individual should be actively monitored, please update the
              record’s Monitoring Status.
            </p>
            {this.props.has_group_members && this.renderRadioButtons()}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary btn-square" onClick={toggle}>
              Cancel
            </Button>
            <Button variant="primary btn-square" onClick={submit} disabled={this.state.loading}>
              {this.state.loading && (
                <React.Fragment>
                  <span className="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;
                </React.Fragment>
              )}
              Submit
            </Button>
          </Modal.Footer>
        </Modal>
      );
    } else if (this.state.case_status === '') {
      return (
        <Modal size="lg" show centered onHide={toggle}>
          <Modal.Header>
            <Modal.Title>{title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <p>Are you sure you want to change case status from {this.props.patient.case_status} to blank? The monitoree will remain in the same workflow.</p>
            {this.props.has_group_members && this.renderRadioButtons()}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary btn-square" onClick={toggle}>
              Cancel
            </Button>
            <Button variant="primary btn-square" onClick={submit} disabled={this.state.loading}>
              {this.state.loading && (
                <React.Fragment>
                  <span className="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;
                </React.Fragment>
              )}
              Submit
            </Button>
          </Modal.Footer>
        </Modal>
      );
    } else if (
      this.props.patient.isolation &&
      !this.state.confirmedOrProbable &&
      (this.props.patient.case_status === 'Confirmed' || this.props.patient.case_status === 'Probable')
    ) {
      return (
        <Modal size="lg" show centered onHide={toggle}>
          <Modal.Header>
            <Modal.Title>{title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            {this.props.patient.monitoring ? (
              <p>
                This case will be moved to the exposure workflow and will be placed in the Symptomatic, Non-Reporting, or Asymptomatic line list as appropriate
                to continue exposure monitoring.
              </p>
            ) : (
              <p>
                This case will be moved to the exposure workflow and will be placed in the Closed line list. If this individual should be actively monitored,
                please update the record’s Monitoring Status.
              </p>
            )}
            {this.props.has_group_members && this.renderRadioButtons()}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary btn-square" onClick={toggle}>
              Cancel
            </Button>
            <Button variant="primary btn-square" onClick={submit} disabled={this.state.loading}>
              {this.state.loading && (
                <React.Fragment>
                  <span className="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;
                </React.Fragment>
              )}
              Submit
            </Button>
          </Modal.Footer>
        </Modal>
      );
    } else if (this.state.confirmedOrProbable) {
      return (
        <Modal size="lg" show centered onHide={toggle}>
          <Modal.Header>
            <Modal.Title>{title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <p>Please select what you would like to do:</p>
            <Form.Control as="select" className="form-control-lg" id="monitoring_option" onChange={this.handleChange} value={this.state.monitoring_option}>
              <option></option>
              <option>End Monitoring</option>
              <option>Continue Monitoring in Isolation Workflow</option>
            </Form.Control>
            {this.state.monitoring_option === 'End Monitoring' && (
              <p className="pt-4 mb-0">
                The case status for the selected record will be updated to {this.state.case_status} and moved to the closed line list in the current workflow.
              </p>
            )}
            {this.state.monitoring_option === 'Continue Monitoring in Isolation Workflow' && (
              <p className="pt-4 mb-0">
                The case status for the selected record will be updated to {this.state.case_status} and moved to the appropriate line list in the Isolation
                Workflow.
              </p>
            )}
            {this.props.has_group_members && this.renderRadioButtons()}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary btn-square" onClick={toggle}>
              Cancel
            </Button>
            <Button variant="primary btn-square" onClick={submit} disabled={this.state.monitoring_option === '' || this.state.loading}>
              {this.state.loading && (
                <React.Fragment>
                  <span className="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;
                </React.Fragment>
              )}
              Submit
            </Button>
          </Modal.Footer>
        </Modal>
      );
    } else if (!this.state.confirmedOrProbable) {
      return (
        <Modal size="lg" show centered onHide={toggle}>
          <Modal.Header>
            <Modal.Title>{title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <p>
              The case status for the selected record will be updated to {this.state.case_status} and moved to the appropriate line list in the Exposure
              Workflow.
            </p>
            {this.props.has_group_members && this.renderRadioButtons()}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary btn-square" onClick={toggle}>
              Cancel
            </Button>
            <Button variant="primary btn-square" onClick={submit} disabled={this.state.loading}>
              {this.state.loading && (
                <React.Fragment>
                  <span className="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;
                </React.Fragment>
              )}
              Submit
            </Button>
          </Modal.Footer>
        </Modal>
      );
    }
  }

  render() {
    return (
      <React.Fragment>
        <div className="disabled">
          <Form.Label className="nav-input-label">
            CASE STATUS
            <InfoTooltip tooltipTextKey="caseStatus" location="right"></InfoTooltip>
          </Form.Label>
          <Form.Control as="select" className="form-control-lg" id="case_status" onChange={this.handleChange} value={this.state.case_status}>
            <option></option>
            <option>Confirmed</option>
            <option>Probable</option>
            <option>Suspect</option>
            <option>Unknown</option>
            <option>Not a Case</option>
          </Form.Control>
        </div>
        {this.state.showCaseStatusModal && this.createModal('Case Status', this.toggleCaseStatusModal, this.submit)}
      </React.Fragment>
    );
  }
}

CaseStatus.propTypes = {
  patient: PropTypes.object,
  authenticity_token: PropTypes.string,
  has_group_members: PropTypes.bool,
};

export default CaseStatus;
