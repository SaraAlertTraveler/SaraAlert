import React from 'react';
import PropTypes from 'prop-types';
import axios from 'axios';
import 'react-bootstrap-table/dist/react-bootstrap-table.min.css';
import { Button, ButtonGroup } from 'react-bootstrap';
import { BootstrapTable, TableHeaderColumn, InsertModalHeader, InsertModalFooter } from 'react-bootstrap-table';

class Admin extends React.Component {
  constructor(props) {
    super(props);
    var dataLen = props.data.length;
    for (var i = 0; i < dataLen; i++) {
      if (Array.isArray(props.data[parseInt(i)]['jurisdiction_path'])) {
        props.data[parseInt(i)]['jurisdiction_path'] = props.data[parseInt(i)]['jurisdiction_path'].join(',');
      }
    }
    this.onAddRow = this.onAddRow.bind(this);
    this.afterSaveCell = this.afterSaveCell.bind(this);
  }

  onAddRow(row) {
    if (this.props.data.map(a => a.email).includes(row.email)) {
      alert('User already exists');
      return;
    }
    axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
    let submit_data = { jurisdiction: this.props.jurisdiction_paths[row.jurisdiction_path.replace(/,/g, ', ')], email: row.email, role_title: row.role };
    let send_result = axios({
      method: 'post',
      url: window.BASE_PATH + '/admin/create_user',
      data: submit_data,
    })
      .then(() => {
        return true;
      })
      .catch(() => {
        return false;
      });

    send_result.then(success => {
      if (success) {
        this.props.data.push(row);
        this.setState({ data: this.props.data });
      } else {
        alert('Error adding new user.');
      }
    });
  }

  afterSaveCell(row) {
    axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
    let submit_data = { jurisdiction: this.props.jurisdiction_paths[row.jurisdiction_path.replace(/,/g, ', ')], email: row.email, role_title: row.role };
    let send_result = axios({
      method: 'post',
      url: window.BASE_PATH + '/admin/edit_user',
      data: submit_data,
    })
      .then(() => {
        return true;
      })
      .catch(() => {
        return false;
      });
    send_result.then(success => {
      if (success) {
        this.setState({ data: this.props.data });
      } else {
        alert('Error editing user.');
      }
    });
  }

  addUserModalHeader = () => {
    return <InsertModalHeader title="Add User" hideClose={true} />;
  };

  addUserModalFooter = () => {
    return <InsertModalFooter saveBtnText="Add User" />;
  };

  addUserButton = onClick => {
    return (
      <Button variant="primary" size="md" className="btn-block btn-square" onClick={onClick}>
        Add User
      </Button>
    );
  };

  createCustomButtonGroup = props => {
    return <ButtonGroup className="mr-2 pb-1">{props.insertBtn}</ButtonGroup>;
  };

  onClickUnlockButton = row => {
    axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
    let submit_data = { email: row.email };
    let send_result = axios({
      method: 'post',
      url: window.BASE_PATH + '/admin/unlock_user',
      data: submit_data,
    })
      .then(() => {
        return true;
      })
      .catch(() => {
        return false;
      });
    send_result.then(success => {
      if (success) {
        this.props.data.find(r => r.email === row.email).locked = 'Unlocked';
        this.setState({ data: this.props.data });
      } else {
        alert('Error unlocking user.');
      }
    });
  };

  onClickLockButton = row => {
    axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
    let submit_data = { email: row.email };
    let send_result = axios({
      method: 'post',
      url: window.BASE_PATH + '/admin/lock_user',
      data: submit_data,
    })
      .then(() => {
        return true;
      })
      .catch(() => {
        return false;
      });
    send_result.then(success => {
      if (success) {
        this.props.data.find(r => r.email === row.email).locked = 'Locked';
        this.setState({ data: this.props.data });
      } else {
        alert('Error locking user.');
      }
    });
  };

  onClickSendResetButton = row => {
    axios.defaults.headers.common['X-CSRF-Token'] = this.props.authenticity_token;
    let submit_data = { email: row.email };
    let send_result = axios({
      method: 'post',
      url: window.BASE_PATH + '/admin/reset_password',
      data: submit_data,
    })
      .then(() => {
        return true;
      })
      .catch(() => {
        return false;
      });
    send_result.then(success => {
      if (success) {
        this.setState({ data: this.props.data });
      } else {
        alert('Error sending password reset.');
      }
    });
  };

  // eslint-disable-next-line no-unused-vars
  lockUnlockButton = (cell, row, enumObject, rowIndex) => {
    if (row['locked'] === 'Unlocked') {
      return (
        <Button variant="primary" size="md" className="btn-block btn-square btn-danger" onClick={() => this.onClickLockButton(row)}>
          Lock
        </Button>
      );
    } else {
      return (
        <Button variant="primary" size="md" className="btn-block btn-square btn-success" onClick={() => this.onClickUnlockButton(row)}>
          Unlock
        </Button>
      );
    }
  };

  // eslint-disable-next-line no-unused-vars
  sendResetButton = (cell, row, enumObject, rowIndex) => {
    return (
      <Button variant="primary" size="md" className="btn-block btn-square btn-info" onClick={() => this.onClickSendResetButton(row)}>
        Reset Password and Send Email
      </Button>
    );
  };

  render() {
    const options = {
      onAddRow: this.onAddRow,
      btnGroup: this.createCustomButtonGroup,
      insertBtn: this.addUserButton,
      insertModalHeader: this.addUserModalHeader,
      insertModalFooter: this.addUserModalFooter,
    };
    const cellEdit = {
      mode: 'click',
      afterSaveCell: this.afterSaveCell,
      blurToSave: true,
    };
    return (
      <BootstrapTable data={this.props.data} cellEdit={cellEdit} insertRow={true} options={options} className="table table-striped">
        <TableHeaderColumn dataField="email" isKey>
          Email
        </TableHeaderColumn>
        <TableHeaderColumn
          dataField="jurisdiction_path"
          editable={{ type: 'select', options: { values: Object.keys(this.props.jurisdiction_paths).map(p => p.replace(/, /g, ',')) } }}>
          Jurisdiction
        </TableHeaderColumn>
        <TableHeaderColumn dataField="role" editable={{ type: 'select', options: { values: this.props.role_types } }}>
          Role
        </TableHeaderColumn>
        <TableHeaderColumn dataField="failed_attempts" editable={false}>
          Failed Login Attempts
        </TableHeaderColumn>
        <TableHeaderColumn dataField="locked" editable={false}>
          Status
        </TableHeaderColumn>
        <TableHeaderColumn dataField="button" dataFormat={this.lockUnlockButton.bind(this)} editable={false}>
          Lock/Unlock
        </TableHeaderColumn>
        <TableHeaderColumn dataField="button" dataFormat={this.sendResetButton.bind(this)} editable={false}>
          Send Password Reset E-mail
        </TableHeaderColumn>
      </BootstrapTable>
    );
  }
}

Admin.propTypes = {
  data: PropTypes.array,
  authenticity_token: PropTypes.string,
  jurisdiction_paths: PropTypes.object,
  roles: PropTypes.array,
  role_types: PropTypes.array,
};

export default Admin;
